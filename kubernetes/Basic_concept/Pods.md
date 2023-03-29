
# Pod

![pods](https://viblo.asia/uploads/b6c657ee-bd66-4776-9360-93f04dc408f3.png)

Pod là một đơn vị nhỏ nhất có thể được triển khai và quản lý bởi k8s.

Pod là 1 nhóm (1 trở lên) các container thực hiện một mục đích
nào đó, như là chạy software nào đó.

Nhóm này chia sẻ không gian lưu trữ, địa chỉ IP với nhau.

Pod thì được tạo ra hoặc xóa tùy thuộc vào yêu cầu của dự án.

Ví dụ file manifest cho pod:

  ```yaml
  apiVersion: v1
  kind: Pod                                      # 1
  metadata:
    name: client                                 # 2
  spec:                                          # 3
    containers:
      - image: client                            # 4
        name: client                             # 5
        ports:
          - containerPort: 80                    # 6
  ```

* Trong đó:

**Kind**: Đánh dấu xem tài nguyên Kubernetes mà ta sẽ tạo với manifest file này. Ở đây ta muốn tạo 1 pod mới, vậy trường này có giá trị là Pod
**Name**: tên của resource, ta cũng gọi nó là frontend luôn cho tiện.
**Spec**: Object mà sẽ định nghĩa trạng thái cho resource. Thứ quan trọng nhất ở đây là danh sách các container trong pod.
**Image**: image dùng để bắt đầu trong pod.
**Name**: Tên của container trong pod.
**Container Port**: Cổng mà container đó gắn với.

# Label

Label là nhãn để quản lý các các resource

Resource có thể có nhiều hơn 1 label miễn là khóa của nó là duy nhất

Ví dụ sau sẽ tạo ra một pod và một service cho pod đó thống qua label

  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: client
  labels: # => thêm nhãn labels ở đây, cho cả   client và client2
    app: client
  spec:
    containers:
      - image: client
        imagePullPolicy: Never
        name: client
        ports:
          - containerPort: 80
  ```

File manifest cho service:

```yaml
    apiVersion: v1
    kind: Service              # 1
    metadata:
      name: client-lb
    spec:
      type: LoadBalancer       # 2
      ports:
      - port: 80               # 3
        protocol: TCP          # 4
        targetPort: 80         # 5
      selector:                # 6
        app: client
```

Trong đó:

**Kind**: Khác với các Pod, trường này của service dĩ nhiên sẽ có giá trị là Service rồi

**Type**: Đặc tả thêm về loại của Service, ở đây service của ta đóng vai trò là 1 load-balancer

**Port**: Cổng mà service sẽ nhận request vào

**Protocol**: Giao thức kết nối

 **TargetPort**: Cổng mà các request tới được foward về

 **Selector**: Nơi định nghĩa selector mà dùng để lựa chọn các pod nào service sẽ kết nối tới. Ở đây là các pod nào có gắn
 **label** client.

Liệt kê

```md
root@k8s-master:~# kubectl get pod
NAME                               READY   STATUS    RESTARTS   AGE
grafana-cc4cc59bb-tvggh            1/1     Running   6          2d
influxdb-0                         1/1     Running   7          2d
wordpress-5bbd7fd785-n7lgf         1/1     Running   8          2d1h
wordpress-mysql-85ff59475f-2tltf   1/1     Running   7          2d18h
```
