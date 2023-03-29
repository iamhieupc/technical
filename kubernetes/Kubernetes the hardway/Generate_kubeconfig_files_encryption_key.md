# Tạo kubeconfig file và encryption key để xác thực

## Kubeconfig

**Kubeconfig** dùng để xác thực giữa cách thành phần của kubernetes và người sử dụng, kube config gồm 3 thành phần chính:

|   Thành phần  |   Tác dụng|
|---            |---|
|   Cluster     |   api-server IP và các cert được mã hóa `base64`|
|   Users       |   Thông tin người dùng như ai đang xác thực, cert, key hoặc service account token|
|   Context     |   Giữ thông tin của Cluster và User. Cần nếu như sử dụng nhiều cluster hoặc user|

Các thành phần cần có kubeconfig

![kube](https://veerendra2.github.io/assets/kubeconfig.png)

Tạo thư mục để chưa file config được tạo ra:

```sh
mkdir configs
```

### Tạo kubeconfig cho worker

Chú ý:
Phần `user` trong kubeconfig nên đặt là  system:node:<Worker_name> để đảm bảo kubelet được xác thực bởi đúng Kubernetes Node Authorizer.

```sh
for instance in k8s-worker1 k8s-worker2; do
  kubectl config set-cluster quanlm-kubernetes \
    --certificate-authority=pki/ca/ca.pem \
    --embed-certs=true \
    --server=https://192.168.122.15:6443 \
    --kubeconfig=configs/clients/${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=pki/clients/${instance}.pem \
    --client-key=pki/clients/${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=configs/clients/${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=quanlm-kubernetes \
    --user=system:node:${instance} \
    --kubeconfig=configs/clients/${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=configs/clients/${instance}.kubeconfig
done
```

### Tạo kubeconfig cho kube-proxy

```sh
kubectl config set-cluster quanlm-kubernetes \
  --certificate-authority=pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://192.168.122.15:6443 \
  --kubeconfig=configs/proxy/kube-proxy.kubeconfig

kubectl config set-credentials system:kube-proxy \
  --client-certificate=pki/proxy/kube-proxy.pem \
  --client-key=pki/proxy/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=configs/proxy/kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=quanlm-kubernetes \
  --user=system:kube-proxy \
  --kubeconfig=configs/proxy/kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=configs/proxy/kube-proxy.kubeconfig
```

### Tạo kubeconfig cho kube-controller-manager

```sh
kubectl config set-cluster quanlm-kubernetes \
  --certificate-authority=pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=configs/controller/kube-controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=pki/controller/kube-controller-manager.pem \
  --client-key=pki/controller/kube-controller-manager-key.pem \
  --embed-certs=true \
  --kubeconfig=configs/controller/kube-controller-manager.kubeconfig

kubectl config set-context default \
  --cluster=quanlm-kubernetes \
  --user=system:kube-controller-manager \
  --kubeconfig=configs/controller/kube-controller-manager.kubeconfig

kubectl config use-context default --kubeconfig=configs/controller/kube-controller-manager.kubeconfig
```

### Tạo kubeconfig cho kube-scheduler

```sh
kubectl config set-cluster quanlm-kubernetes \
  --certificate-authority=pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=configs/scheduler/kube-scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
  --client-certificate=pki/scheduler/kube-scheduler.pem \
  --client-key=pki/scheduler/kube-scheduler-key.pem \
  --embed-certs=true \
  --kubeconfig=configs/scheduler/kube-scheduler.kubeconfig

kubectl config set-context default \
  --cluster=quanlm-kubernetes \
  --user=system:kube-scheduler \
  --kubeconfig=configs/scheduler/kube-scheduler.kubeconfig

kubectl config use-context default --kubeconfig=configs/scheduler/kube-scheduler.kubeconfig
```

### Tạo kubeconfig cho admin

```sh
kubectl config set-cluster quanlm-kubernetes \
  --certificate-authority=pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=configs/admin/admin.kubeconfig

kubectl config set-credentials admin \
  --client-certificate=pki/admin/admin.pem \
  --client-key=pki/admin/admin-key.pem \
  --embed-certs=true \
  --kubeconfig=configs/admin/admin.kubeconfig

kubectl config set-context default \
  --cluster=quanlm-kubernetes \
  --user=admin \
  --kubeconfig=configs/admin/admin.kubeconfig

kubectl config use-context default --kubeconfig=admin.kubeconfig
```

Kết quả:

```sh
k8s-the-hard-way/configs/
├── admin
│   └── admin.kubeconfig
├── clients
│   ├── k8s-worker1.kubeconfig
│   └── k8s-worker2.kubeconfig
├── controller
│   └── kube-controller-manager.kubeconfig
├── proxy
│   └── kube-proxy.kubeconfig
└── scheduler
    └── kube-scheduler.kubeconfig

```

### Chuyển file kubeconfig đến node cần thiết

Chuyển đến worker

```sh
for instance in k8s-worker1 k8s-worker2; do
  scp configs/clients/${instance}.kubeconfig configs/proxy/kube-proxy.kubeconfig ${instance}:~/
done
```

Chuyển đến master

```sh
for instance in k8s-master; do
  scp configs/admin/admin.kubeconfig configs/controller/kube-controller-manager.kubeconfig configs/scheduler/kube-scheduler.kubeconfig ${instance}:~/
done
```

## Tạo data encryption key

Sử dụng để mã hóa dữ liệu giữa các node

```sh
mkdir data-encryption

ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

cat > data-encryption/encryption-config.yaml <<EOF
apiVersion: v1
kind: EncryptionConfig
resources:
  - resources:
      - secrets
    providers:
    - identity: {}
    - aescbc:
        keys:
        - name: key1
          secret: ${ENCRYPTION_KEY}
EOF
```

Chuyển đến master

```sh
for instance in k8s-master; do
  scp data-encryption/encryption-config.yaml ${instance}:~/
done
```
