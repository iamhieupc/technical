## Giới thiệu
ECS hay còn được gọi là Amazon Elastic Container Service là một service quản lý container có tính scale cao và nhanh. Dễ dàng run, stop, hay quản lý docker container ở trong một cluster. Bạn có thể host một serverless infrastructure bằng cách chạy service hay task sử dụng Fragate launch type.

## Các tính năng của ECS

Amazon ECS là một dịch vụ theo region, nó đơn giản hoá việc chạy ứng dụng containers trên nhiều AZ trong cùng một Region. Bạn có thể tạo một ECS cluster bên trong một VPC mới hoặc cũ. Sau khi một cluster được khởi tạo và chạy, bạn có thể định nghĩa các task và services mà nó chỉ định Docker contatainer image sẽ chạy thông qua clusters.

Các container images được lưu và pull về từ container registeries nó có thể tồn tại bên trong or bên ngoài AWS infrastructure của bạn

## Task definition
Task definition là một text file (json format). Nó sẽ mô tả 1 hoặc nhiều container (tối đa là 10) để hình thành nên ứng dụng của bạn. Task definition sẽ chỉ ra một vài parameter cho ứng dụng như container nào sẽ được sử dụng, launch type sẽ được dùng, những port nào sẽ được mở cho ứng dụng và data volume gì sẽ được với containers trong task.

## Lab deploy app to ECS

1, Create repo in ECR
2, push image to ECR
3, Tạo ECS
4, Tạo Task Definition
5, Tạo cluster
6, Tạo Service để launch ec2