## Introduction

TLS hay còn gọi là transport layer security, tiền thân của nó là SSL là giao thức web protocol sử dụng để bảo vẹ và giải mã trafic bên ngoài network.

Với TLS/SSL, server có thể gửi traffic an toàn giữa server và clients mà không có khả năng bị chặn từ các message bên ngoài. Hệ thống certificate cũng bao gồm user trong việc xác thực định danh của web mà user connect đến.

### Step 1 — Creating the SSL Certificate
TLS/SSL là sự kết hopej bởi 1 public certificate và 1 private key, public certificate được gửi cùng với các request, private key sẽ được lưu trên server.

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt

Sử dụng openssl để tạo 1 file cert