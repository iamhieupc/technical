## Giới thiệu
Docker là su thế mới của công nghệ. Docker chạy trong một không gian độc lập, Nó nhệ hơn so với chạy bằng Vms vì nó không có tài nguyên vật lý hoặc không yêu cầu OS phải được install.

## Dockerd
Dockerd là 1 high-level container runtime, giống như kiểu container manager, nó là nền quản lý vòng đời container trên 1 máy chủ đơn: create, start, ..

## Containerd
Là 1 runtime interface
Containerd được thiết kế có thể nhúng vào trong các hệ thống lớn một cách dễ dàng hơn. Docker sử dụng containerd bên dưới để chạy containers.
Cũng có thể thao tác trực tiếp với containerd thông qua ctr.

## runc
runc là 1 low-level runtime