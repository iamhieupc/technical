# Cung cấp CA và TLS Certificates

Để đảm bảo giao tiếp giữa các thành phần của kubernetes được mã hóa. Cần tạo public key certificates and private keys, ở đây sẽ sử dụng **CloudFlare’s PKI toolkit**

![cert](https://veerendra2.github.io/assets/certificates.png)

## Cài đặt cfssl

Cài đặt cfssl như sau:

```sh
wget -q --show-progress --https-only --timestamping https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64

chmod +x cfssl_linux-amd64 cfssljson_linux-amd64
sudo mv cfssl_linux-amd64 /usr/local/bin/cfssl
sudo mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
```

## Cung cấp CA

Chúng ta sẽ tạo 1 vài thư mục để chứa các TLS certs tương ứng với tên gọi:

```sh
mkdir -p pki/{admin,api,ca,clients,controller,proxy,scheduler,service-account}
```

Tạo 1 số biến để tiện cho tạo CA,TLS sau này:

```sh
TLS_C="VN"
TLS_L="HN"
TLS_OU="quanlm kubernetes"
TLS_ST="HN"
```

### Tạo CA config file và certificate

```sh
cat > pki/ca/ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat > pki/ca/ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "${TLS_C}",
      "L": "${TLS_L}",
      "O": "Kubernetes",
      "OU": "${TLS_OU}",
      "ST": "${TLS_ST}"
    }
  ]
}
EOF

cfssl gencert -initca pki/ca/ca-csr.json | cfssljson -bare pki/ca/ca
```

Kết quả:

```sh
root@k8s-master:~/k8s-the-hard-way/pki/ca# ls
ca-config.json  ca-csr.json  ca-key.pem  ca.csr  ca.pem
```

## Tạo TLS Certificates

### Tạo admin user config files và certificates**

```sh
cat > pki/admin/admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "${TLS_C}",
      "L": "${TLS_L}",
      "O": "system:masters",
      "OU": "${TLS_OU}",
      "ST": "${TLS_ST}"
    }
  ]
}
EOF

cfssl gencert \
  -ca=pki/ca/ca.pem \
  -ca-key=pki/ca/ca-key.pem \
  -config=pki/ca/ca-config.json \
  -profile=kubernetes \
  pki/admin/admin-csr.json | cfssljson -bare pki/admin/admin
```

### Tạo worker cert và keys

```sh
for instance in k8s-worker1 k8s-worker2; do
cat > pki/clients/${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "${TLS_C}",
      "L": "${TLS_L}",
      "O": "system:nodes",
      "OU": "${TLS_OU}",
      "ST": "${TLS_ST}"
    }
  ]
}
EOF

EXTERNAL_IP=$(curl -s -4 https://ifconfig.co)
INTERNAL_IP=$(ip addr show ens3 | grep -Po 'inet \K[\d.]+')

cfssl gencert \
  -ca=pki/ca/ca.pem \
  -ca-key=pki/ca/ca-key.pem \
  -config=pki/ca/ca-config.json \
  -hostname=${instance},${INTERNAL_IP},${EXTERNAL_IP} \
  -profile=kubernetes \
  pki/clients/${instance}-csr.json | cfssljson -bare pki/clients/${instance}

done
```

### Tạo  kube-controller-manager cert và key

```sh
cat > pki/controller/kube-controller-manager-csr.json <<EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "${TLS_C}",
      "L": "${TLS_L}",
      "O": "system:kube-controller-manager",
      "OU": "${TLS_OU}",
      "ST": "${TLS_ST}"
    }
  ]
}
EOF

cfssl gencert \
  -ca=pki/ca/ca.pem \
  -ca-key=pki/ca/ca-key.pem \
  -config=pki/ca/ca-config.json \
  -profile=kubernetes \
  pki/controller/kube-controller-manager-csr.json | cfssljson -bare pki/controller/kube-controller-manager
```

### Tạo kube-proxy cert và key

```sh
cat > pki/proxy/kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "${TLS_C}",
      "L": "${TLS_L}",
      "O": "system:node-proxier",
      "OU": "${TLS_OU}",
      "ST": "${TLS_ST}"
    }
  ]
}
EOF

cfssl gencert \
  -ca=pki/ca/ca.pem \
  -ca-key=pki/ca/ca-key.pem \
  -config=pki/ca/ca-config.json \
  -profile=kubernetes \
  pki/proxy/kube-proxy-csr.json | cfssljson -bare pki/proxy/kube-proxy
```

### Tạo scheduler cert và key

```sh
cat > pki/scheduler/kube-scheduler-csr.json <<EOF
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "${TLS_C}",
      "L": "${TLS_L}",
      "O": "system:kube-scheduler",
      "OU": "${TLS_OU}",
      "ST": "${TLS_ST}"
    }
  ]
}
EOF

cfssl gencert \
  -ca=pki/ca/ca.pem \
  -ca-key=pki/ca/ca-key.pem \
  -config=pki/ca/ca-config.json \
  -profile=kubernetes \
  pki/scheduler/kube-scheduler-csr.json | cfssljson -bare pki/scheduler/kube-scheduler
```

### Tạo api-server cert và key

```sh
cat > pki/api/kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "${TLS_C}",
      "L": "${TLS_L}",
      "O": "Kubernetes",
      "OU": "${TLS_OU}",
      "ST": "${TLS_ST}"
    }
  ]
}
EOF

cfssl gencert \
  -ca=pki/ca/ca.pem \
  -ca-key=pki/ca/ca-key.pem \
  -config=pki/ca/ca-config.json \
  -hostname=10.32.0.1,192.168.122.15,127.0.0.1,kubernetes.default \
  -profile=kubernetes \
  pki/api/kubernetes-csr.json | cfssljson -bare pki/api/kubernetes
```

### Tạo SA cert và key

```sh
cat > pki/service-account/service-account-csr.json <<EOF
{
  "CN": "service-accounts",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "${TLS_C}",
      "L": "${TLS_L}",
      "O": "Kubernetes",
      "OU": "${TLS_OU}",
      "ST": "${TLS_ST}"
    }
  ]
}
EOF

cfssl gencert \
  -ca=pki/ca/ca.pem \
  -ca-key=pki/ca/ca-key.pem \
  -config=pki/ca/ca-config.json \
  -profile=kubernetes \
  pki/service-account/service-account-csr.json | cfssljson -bare pki/service-account/service-account
```

Kết quả:

```sh
k8s-the-hard-way-bare-metal/pki/
├── admin
│   ├── admin-csr.json
│   ├── admin-key.pem
│   ├── admin.csr
│   └── admin.pem
├── api
│   ├── kubernetes-csr.json
│   ├── kubernetes-key.pem
│   ├── kubernetes.csr
│   └── kubernetes.pem
├── ca
│   ├── ca-config.json
│   ├── ca-csr.json
│   ├── ca-key.pem
│   ├── ca.csr
│   └── ca.pem
├── clients
│   ├── k8s-worker1-csr.json
│   ├── k8s-worker1-key.pem
│   ├── k8s-worker1.csr
│   ├── k8s-worker1.pem
│   ├── k8s-worker2-csr.json
│   ├── k8s-worker2-key.pem
│   ├── k8s-worker2.csr
│   └── k8s-worker2.pem
├── controller
│   ├── kube-controller-manager-csr.json
│   ├── kube-controller-manager-key.pem
│   ├── kube-controller-manager.csr
│   └── kube-controller-manager.pem
├── proxy
│   ├── kube-proxy-csr.json
│   ├── kube-proxy-key.pem
│   ├── kube-proxy.csr
│   └── kube-proxy.pem
├── scheduler
│   ├── kube-scheduler-csr.json
│   ├── kube-scheduler-key.pem
│   ├── kube-scheduler.csr
│   └── kube-scheduler.pem
└── service-account
    ├── service-account-csr.json
    ├── service-account-key.pem
    ├── service-account.csr
    └── service-account.pem

```

### Chuyển cert, key đến đúng node cần thiết

Chuyển đến các worker:

```sh
for instance in k8s-worker1 k8s-worker2; do
  scp pki/ca/ca.pem pki/clients/${instance}-key.pem pki/clients/${instance}.pem ${instance}:~/
done
```

Chuyển đến master:

```sh
for instance in k8s-master; do
  scp pki/ca/ca.pem pki/ca/ca-key.pem pki/api/kubernetes-key.pem pki/api/kubernetes.pem pki/service-account/service-account-key.pem pki/service-account/service-account.pem ${instance}:~/
done
```
