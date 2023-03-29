# Kubernetes là gì

Kubernetes, hay còn được gọi **k8s** là một nền tảng mã nguồn mở tự động hoá việc quản lý, scaling và triển khai ứng dụng dưới dạng container hay còn gọi là **Container orchestration engine**. K8s loại bỏ rất nhiều các quy trình thủ công liên quan đến việc triển khai và mở rộng các ứng dụng được container.

**Kubernetes orchestration** cho phép xây dựng các dịch vụ mở rộng ra nhiều containers. Lập lịch các containers đó trên một cụm, mở rộng các containers và quản lý tình trạng của các containers theo thời gian.

#### Các vấn đề Kubernetes có thể giải quyết

* Quản lý hàng loạt docker host
* Container Scheduling
* Rolling update
* Scaling/Auto Scaling
* Monitor vòng đời và tình trạng sống chết của container.
* Self-hearing trong trường hợp có lỗi xãy ra. (Có khả năng phát hiện và tự correct lỗi)
* Service discovery
* Load balancing
* Quản lý data, work node, log
* Infrastructure as Code
* Liên kết và mở rộng với các hệ thống khác

#### Các thành phần của kubernetes

**Tổng quan:** ![kuberarchitech1](https://topdev.vn/blog/wp-content/uploads/2019/05/Kubernetes-Architecture.png)

Kubernetes có thể được triển khai trên một hoặc nhiều máy vật lý, máy ảo hoặc cả máy vật lý và máy ảo để tạo thành cụm cluster. Cụm cluster này chịu sự điều khiển của Kubernetes và sinh ra các container khi người dùng yêu cầu. Kiến trúc logic của Kubernetes bao gồm 02 thành phần chính dựa theo vai trò của các node, đó là: Master node và Worker node

* Master node: Đóng vai trò là thành phần Control plane, điều khiển toàn bộ các hoạt động chung và kiểm soát các container trên node worker.

    Các thành phần chính trên master node bao gồm: **API-server, Controller-manager, Schedule, Etcd**

* Worker node: Vai trò chính của worker node là môi trường để chạy các container mà người dùng yêu cầu, do vậy thành phần chính của worker node bao gồm: **kubelet, kube-proxy**

**Chi tiết:**![kuberarchitech2](https://d33wubrfki0l68.cloudfront.net/7016517375d10c702489167e704dcb99e570df85/7bb53/images/docs/components-of-kubernetes.png)

#### Các thành phần chính trong cụm cluster K8S bao gồm

##### etcd

* Etcd là một thành phần database phân tán, sử dụng ghi dữ liệu theo cơ chế key/value trong K8S cluster.

* Etcd được cài trên **node master** và lưu tất cả các thông tin trong Cluser.

* Etcd sử dụng port 2380 để listening từng request và port 2379 để client gửi request tới.
  
##### API-server

* API server là thành phần tiếp nhận yêu cầu của hệ thống K8S thông qua REST, tức là nó tiếp nhận các chỉ thị từ người dùng cho đến các services trong hệ thống Cluster thông qua API - có nghĩa là người dùng hoặc các service khác trong cụm cluster có thể tương tác tới K8S thông qua HTTP/HTTPS.

* API-server hoạt động trên port 6443 (HTTPS) và 8080 (HTTP).

* API-server nằm trên **node master**.

##### Controller-manager

* Controller-manager là thành phần quản lý trong K8S, nó có nhiệm vụ xử lý các tác vụ trong cụm cluster để đảm bảo hoạt động của các tài nguyên trong cụm cluster. Controller-manager có các thành phần bên trong như sau:

* Node Controller: Tiếp nhận và trả lời các thông báo khi có một node bị down.

* Replication Controller: Đảm bảo các công việc duy trì chính xác số lượng bản replicate và phân phối các container trong pod (Pod tạm hình dung là một tập hợp các container khi người dùng có nhu cầu tạo ra và cùng thực hiện chạy một ứng dụng).

* Endpoints Controller: Populates the Endpoints object (i.e., join Services & Pods).

* Service Account & Token Controllers: Tạo ra các accounts và token để có thể sử dụng được các API cho các namespaces.

* Controller-manager hoạt động trên **node master** và sử dụng port 10252.

##### Scheduler

* Kube-scheduler có nhiệm vụ quan sát để lựa chọn ra các node mỗi khi có yêu cầu tạo pod. Nó sẽ lựa chọn các node sao cho phù hợp nhất dựa vào các cơ chế lập lịch mà nó có.

* Kube-scheduler được cài đặt trên **node master** và sử dụng port 10251.

##### Agent - kubelet

* Agent hay chính là kubelet, một thành phần chạy chính trên các **node worker**.

* Khi kube-scheduler đã xác định được một pod được chạy trên node nào thì nó sẽ gửi các thông tin về cấu hình (images, volume ...) tới kubelet trên node đó. Dựa vào thông tin nhận được thì kubelet sẽ tiến hành tạo các container theo yêu cầu.

* Vai trò chính của kubelet là:
  * Theo dõi các pod trên node được gán để hoạt động.
  * Mount các volume cho pod
  * Đảm bảo hoạt động của các container của pod hoạt động tốt trên node đó (node worker có cài docker đó).
  * Report về trạng thái của các pod để cụm cluster biết được xem các container còn hoạt động tốt hay không.

* Kubelet chạy trên các node worker và sử dụng port 10250 và 10255.

##### Proxy

* Các service chỉ hoạt động ở chế độ logic, do vậy muốn bên ngoài có thể truy cập được vào các service này thì cần có thành phần chuyển tiếp các request từ bên ngoài và bên trong.

* Kube-proxy được cài đặt trên các node worker, sử dụng port 31080

##### CLI

* kubectl là thành phần cung cấp câu lệnh để người dùng tương tác với K8S. kubectl có thể chạy trên bất cứ máy nào, miễn là có kết nối được với K8S API-server

#### Các thành phần khác

##### Pod

![pods](https://viblo.asia/uploads/b6c657ee-bd66-4776-9360-93f04dc408f3.png)

* Pod là một đơn vị nhỏ nhất có thể được triển khai và quản lý bởi k8s.
* Pod là 1 nhóm (1 trở lên) các container thực hiện một mục đích nào đó, như là chạy software nào đó.
* Nhóm này chia sẻ không gian lưu trữ, địa chỉ IP với nhau.
* Pod thì được tạo ra hoặc xóa tùy thuộc vào yêu cầu của dự án.
