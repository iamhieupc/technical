# Service Account

ServiceAccounts là resources giống như Pod, Secrets, Configmap... và gắn với namespaces
`default` ServiceAccount được tự động tạo ra cho mỗi namespaces

Danh sách SA:

```md
root@k8s-master:~# kubectl get sa
NAME           SECRETS   AGE
default        1         3d17h
grafana        1         2d22h
grafana-test   1         2d22h
influxdb       1         2d22h

```

Chỉ có pod từ cùng namespace mới có thể dùng ServiceAccount của namespace đó

Ta có thể gán ServiceAcount cho pod bằng cách chỉ định tên accounts đó trong pod. Nếu không chỉ định pod sẽ dùng `defaul` ServiceAccount

Bằng cách gắn SA kahsc nhay vào pod, ta có thể kiểm soát tài nguyên nào pod có thể truy cập đến
