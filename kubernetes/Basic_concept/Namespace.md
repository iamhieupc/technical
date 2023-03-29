# Namespace

Namespace cho phép chia nhỏ những hệ thống phức tạp ra thành các nhóm nhỏ hơn

Namespace cũng có thể dùng để chia nhỏ resource trong môi trường multi-tenant

Trong namespace thì resource phải là duy nhất, đối với 2 namespace thì resource trong đó tên có thể giống nhau

Liệt kê namespace

```md
root@k8s-master:~# kubectl get ns
NAME                   STATUS   AGE
default                Active   2d17h
kube-node-lease        Active   2d17h
kube-public            Active   2d17h
kube-system            Active   2d17h
kubernetes-dashboard   Active   47h
```

Liệt kê pod trong namespace khác default

```md
root@k8s-master:~# kubectl get po --namespace kube-system
NAME                                 READY   STATUS    RESTARTS   AGE
coredns-66bff467f8-k99zb             1/1     Running   5          2d17h
coredns-66bff467f8-t98zq             1/1     Running   5          2d17h
etcd-k8s-master                      1/1     Running   5          2d17h
heapster-6667cb64f9-7hgkv            2/2     Running   12         45h
kube-apiserver-k8s-master            1/1     Running   5          2d17h
kube-controller-manager-k8s-master   1/1     Running   5          2d17h
kube-flannel-ds-amd64-8pr5h          1/1     Running   9          2d16h
kube-flannel-ds-amd64-mxt9z          1/1     Running   11         2d16h
kube-flannel-ds-amd64-zds9m          1/1     Running   6          2d17h
kube-proxy-2cl4x                     1/1     Running   7          2d16h
kube-proxy-bnlhq                     1/1     Running   7          2d16h
kube-proxy-rbjjz                     1/1     Running   5          2d17h
kube-scheduler-k8s-master            1/1     Running   5          2d17h

```

Khi tương tác với namespace khác với default, ta phải thêm `-n (namespace)` khi chạy lệnh `kubectl`

Để tương tác với tất cả namespace, ta chạy thêm `--all-namespace`
