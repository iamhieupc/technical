# Cài đặt DNS

## Cài đặt kube-router

```sh
kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/generic-kuberouter.yaml
```

Kiểm tra

```sh
root@k8s-master:~ kubectl -n kube-system get po --watch
NAME                       READY   STATUS    RESTARTS   AGE
kube-router-4tx2g          1/1     Running   1          23h
kube-router-bl5px          1/1     Running   1          23h

```

## Cài đặt DNS addon

Cài đặt CoreDNS

```sh
kubectl apply -f https://storage.googleapis.com/kubernetes-the-hard-way/coredns.yaml
```

Kiểm tra

```sh
root@k8s-master:~# kubectl get pods -l k8s-app=kube-dns -n kube-system --watch
NAME                       READY   STATUS    RESTARTS   AGE
coredns-68567cdb47-npbhc   1/1     Running   1          23h
coredns-68567cdb47-vvrdv   1/1     Running   1          23h
```

## Kiểm tra hoạt động

```sh
kubectl run busybox --image=busybox:1.28 --command -- sleep 3600
kubectl get pods -l run=busybox

POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")

root@k8s-master:~ kubectl exec -ti $POD_NAME -- nslookup kubernetes
Server:    10.32.0.10
Address 1: 10.32.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kubernetes
Address 1: 10.32.0.1 kubernetes.default.svc.cluster.local
```

Cài đặt wordpress

kustomization.yaml

```sh
secretGenerator:
- name: mysql-pass
  literals:
  - password=YOUR_PASSWORD
resources:
  - mysql-deployment.yaml
  - wordpress-deployment.yaml
```

mysql-deployment.yaml

```sh
apiVersion: v1
kind: Service
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
spec:
  ports:
    - port: 3306
  selector:
    app: wordpress
    tier: mysql
  clusterIP: None
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
  labels:
    app: wordpress
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
---
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
spec:
  selector:
    matchLabels:
      app: wordpress
      tier: mysql
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: mysql
    spec:
      containers:
      - image: mysql:5.6
        name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass
              key: password
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql-pv-claim
```

wordpress-deployment.yaml

```sh
apiVersion: v1
kind: Service
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  ports:
    - port: 80
  selector:
    app: wordpress
    tier: frontend
  type: LoadBalancer
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wp-pv-claim
  labels:
    app: wordpress
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
---
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  selector:
    matchLabels:
      app: wordpress
      tier: frontend
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: frontend
    spec:
      containers:
      - image: wordpress:4.8-apache
        name: wordpress
        env:
        - name: WORDPRESS_DB_HOST
          value: wordpress-mysql
        - name: WORDPRESS_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass
              key: password
        ports:
        - containerPort: 80
          name: wordpress
        volumeMounts:
        - name: wordpress-persistent-storage
          mountPath: /var/www/html
      volumes:
      - name: wordpress-persistent-storage
        persistentVolumeClaim:
          claimName: wp-pv-claim
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: wordpress-pv
  labels:
    app: wordpress
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/v1"
```

Kết quả

```sh
root@k8s-master:~# kubectl get pod
NAME                               READY   STATUS    RESTARTS   AGE
busybox-6697bfc987-szmpq           1/1     Running   6          23h
nginx-6db489d4b7-f2zkr             1/1     Running   1          23h
untrusted                          1/1     Running   1          23h
wordpress-675699f695-hk7hh         1/1     Running   0          8m30s
wordpress-mysql-69dcc4fc49-6pz4d   1/1     Running   0          8m30s
```

```sh
root@k8s-master:~# kubectl get svc
NAME              TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
kubernetes        ClusterIP   10.32.0.1     <none>        443/TCP        25h
nginx             NodePort    10.32.0.131   <none>        80:31700/TCP   23h
wordpress         NodePort    10.32.0.40    <none>        80:32644/TCP   8m45s
wordpress-mysql   ClusterIP   None          <none>        3306/TCP       8m45s
```

![wp](https://raw.githubusercontent.com/lmq1999/123/master/Screenshot%20from%202020-06-26%2015-28-30.png)
