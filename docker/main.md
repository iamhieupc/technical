## Giới thiệu
Docker là su thế mới của công nghệ. Docker chạy trong một không gian độc lập, Nó nhệ hơn so với chạy bằng Vms vì nó không có tài nguyên vật lý hoặc không yêu cầu OS phải được install.

## Dockerd
Dockerd là 1 high-level container runtime, giống như kiểu container manager, nó là nền quản lý vòng đời container trên 1 máy chủ đơn: create, start, ..

## Containerd
Là 1 runtime interface
Là 1 container run time, sử dụng để quản lý container lifecycles, xử lý lơ-level storage and networking tasks và cung cấp API cho container operations. Cung cấp tiêu chuẩn môi trường runtime (OCI), nó được thiết kế để nhẹ và quan tâm đến việc độ tin cậy và đơn giản
Containerd được xây dựng trên runc

Include:
    Hỗ trợ multiple container runtimes, bao gồm runc
    high-level API cho quản lý containers, images, snapshort
    Tích hợp cùng với container registries and phân tán hệ thống, để pill and push container images from remote repo

## runc
runc là 1 low-level runtime
Khi chạy 1 docker container, docker sẽ start new instance of runc to giải phóng container. runc chịu trách nhiệm tạo các môi trường của container, setting ip file system and thực thi các process của container

Một vài key feature của runc:
    Khả năng tương thích với OCI runtime: ddmar bảo rằng những container có thể chạy tên bát kì 1 container runtime nòa khác mà ko phải docker

    hỗ trợ cho linux namespaces

    Tích hợp cùng với container image and registries, tạo nó một cách đơn giản bằng việc pull and run images từ dockerhub

Nói chung runc là 1 thàn phần quan trong trong hệ sinh thái của docker, cung cấp 1 cách đơn giản, hiệu quả để chạy 1 app ảo hóa vớ tính isolation and security cao

## containerd vs runc
runc là 1 low-level runtime, cung cấp 1 simple interface to launch contaienrs
containerd là 1 higher-level container runtime, cung cấp một số features cho việc quản lý vòng đời của container bao gồm quản lý và phân tán image, containerd được xây dựng trên runc và sử dụng runc làm container runtime bên dưới.