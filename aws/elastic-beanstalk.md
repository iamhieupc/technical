## Giới thiệu
Elastic Beanstalk là một dịch vụ theo model PaaS của AWS giúp chúng ta dễ dàng triển khai và mở rộng các ứng dụng web và dịch vụ được phát triển bằng Java, . NET, PHP, Node. js, Python, Ruby, Go và Docker trên những máy chủ quen thuộc như Apache, Nginx, Passenger và IIS.

## Các thành phần cơ bản của EB
<b>EC2 instance</b> - Được cấu hình để chạy các ứng dụng web trên nền tảng bạn chọn. Bao gồm application với version mà bạn đã lựa chọn và Apache hoặc NGINX như một reverse proxy để nhận request

<b>Instance security group</b> - Giúp quản lý inbound outbound của các instance

<b>Load balancer</b> - Bộ cân bằng tải Elastic Load Balancing được định cấu hình để phân phối request đến ứng dụng.

<b>Load balancer security group</b> - Giúp quản lý inbound outbound của ELB

<b>Auto Scaling group</b> - Được định cấu hình để thay thế một phiên bản nếu nó bị terminated hoặc không khả dụng.

<b>Amazon S3 bucket</b> - Nơi lưu trữ mã nguồn, log và các artifacts được tạo ra khi sử dụng Elastic Beanstalk.

<b>Amazon CloudWatch alarms</b> - Hai CloudWatch alarms giám sát tải trên các instance trong môi trường. Được kích hoạt nếu tải quá cao hoặc quá thấp. Khi một alarms được kích hoạt, Auto Scaling group sẽ scale up hoặc scale down.

<b>AWS CloudFormation stack</b> - Sử dụng để khởi chạy các tài nguyên trong môi trường và apply các thay đổi cấu hình.

Domain name - Một domain name route đến ứng dụng, ví dụ: subdomain.region.elasticbeanstalk.com.