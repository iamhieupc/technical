# Bảo mật cho clusternode và mạng

## Sử dụng host node`s namespaces trong pod

### Sử dụng mạng network trong pod

Bình thường thì pod sẽ sử dụng network namespace của riêng pod , nhưng trong 1 số trường hợp cần thiết, pod cũng có thể dùng trực tiếp node network.

```md
apiVersion: v1
kind: Pod
metadata:
    name: pod-with-host-networkUsing the host node’s namespaces in a pod
spec:
    hostNetwork: true
    containers:
    - name: main
        image: alpine
        command: ["/bin/sleep", "999999"]
```

Với giá trị `hostNetwork: true`, ta cho pod sử dụng nodenetwork

### Gán vào hostport mà không cần sử dụng host network

Có 2 cách chính để gán đó là sử dụng `hostport` và `NodePort`

Đối với hostport, kết nối giữa node port được trực tiếp chuyển đến cho pod chạy ở node đó
Đối với NodePort, khi kết nối đến node port thì chuyển tiếp cho pod có thể nằm trên node khác, không nhất thiết phải cùng node

### Sử dụng node's PID và PIC namespaces

Khi cấu hình pod, ta có thể gán

```md
hostPID: true
hostIPC: true
```

để cho phép sử dụng PID và IPC của host

## Cấu hình an ninh cho container

Nhưng cấu hình an ninh cho container

* Specify the user (the user’s ID) under which the process in the container will run.
* Prevent the container from running as root (the default user a container runs
as is usually defined in the container image itself, so you may want to prevent
containers from running as root).
* Run the container in privileged mode, giving it full access to the node’s kernel.
* Configure fine-grained privileges, by adding or dropping capabilities—in con-
trast to giving the container all possible permissions by running it in privi-
leged mode.
* Set SELinux (Security Enhanced Linux) options to strongly lock down a
container.
* Prevent the process from writing to the container’s filesystem.

### Chạy container với user xác định

Để chạy container với user xác định, ta cần phải chỉ định ID của user đó:
`runAsUser: 405`
You need to specify a user ID, not
a username (id 405 corresponds
to the guest user)

### Ngăn chặn container chạy với quyền root

Để chạy container chạy với quyền không phải root, ta cần gán
`runAsNonRoot: true`

### Chạy container với chế độ đặc quyền

Khi mà pod phải làm những quyền như node, bình thường thì không thể có, ta cần phải cho chạy với chế độ đặc quyền:
`privileged: true`

### Thêm khả năng của kernel cho container

Để thêm khả năng của container ta sử dụng

```md
capabilities:
add:
- SYS_TIME
```

### Bỏ tính năng cho container

```md
capabilities:
drop:
- CHOWN
```

Bỏ tính năng này khiến cho container không thể đổi sở hữu của thư mục trong pod

### Ngăn chặn tiến trình ghi lên filesystem của containers

Trong trường hợp muốn tiến trình không được ghi trên container mà chỉ ghi lên thư mục được mount ta sử dụng

```md
securityContext:
readOnlyRootFilesystem: true
volumeMounts:
- name: my-volume
mountPath: /volume
readOnly: false
```

### Chia sẻ volume khi container chạy với user khác nhau

Khi muốn 2 container chạy 2 user khác nhau (khác root) mà dùng chung 1 volume ta sử dụng

```md
securityContext:
fsGroup: 555
supplementalGroups: [666, 777]
```

## Giới hạn chức năng an ninh trong pod

### PodSecurityPolicy resource

PodSecurityPolicy là resource cấp cluster, định nghĩa xem pod có thể, không thể làm những gì

Nhưng chức nặng PodSecurityPolicy có thể làm

* Whether a pod can use the host’s IPC, PID, or Network namespaces
* Which host ports a pod can bind to
* What user IDs a container can run as
* Whether a pod with privileged containers can be created
* Which kernel capabilities are allowed, which are added by default and which are always dropped
* What SELinux labels a container can use
* Whether a container can use a writable root filesystem or not
* Which filesystem groups the container can run as
* Which volume types a pod can use

## Cô lập pod network

### Chi cho phép 1 số pod nhất định kết nối đến

Trong trường hợp chỉ muốn 1 số pod nhất định kết nối đến, pod đó cần phải có label đúng theo.

VD

```md
spec:
  podSelector:
    matchLabels:
      app: database
ingress:
- from:
  - podSelector:
        matchLabels:
            app: webserver
```

Đối với ví dụ này chỉ có những pod với label `app: webserver` có thể kết nối đến pod đc tạo

### Cô lập mạng giữa k8s namespace

```md
spec:
  podSelector:
    matchLabels:
      app: shopping-cart
ingress:
- from:
  - namespaceSelector:
    matchLabels:
        tenant: manning
```

Chỉ cho phép ns  label: `tenant: manning` kết nối đến pod ở ns khác có label :`app=shopping-cart`

### Cô lập sử dụng CIDR

```md
ingress:
- from:
    - ipBlock:
      cidr: 192.168.1.0/24
```

Chỉ cho phép client từ dải 192.168.1.0/24 kết nối đến
