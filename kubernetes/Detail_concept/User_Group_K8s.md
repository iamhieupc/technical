# Users and groups

## Users

K8s phân biệt có 2 loại client kết nối đến API server

* User(người dùng/chúng ta)
* Pods (chính xác hơn là ứng dụng chạy trong pod)

Cả 2 loại kết nối này đều được xác thực thông qua plugins. User được quản lý bởi hệ thống ngoài như là SSO. Pod được quản lý bởi Service Account được lưu trữ trong cụm k8s thông qua resource `Service Account`

Vì không có resource nào đại diện cho user thế nên không thể tạo, sửa, xóa users thông qua API server

## Group

Cả User và Service Accounts đều thuộc về 1 hoặc nhiều group

Group dùng để phân quyền nhiều người dùng cùng lúc thay vì gán cho từng users một.

Một số group đặc biệt:

* **system:unauthenticated** group is used for requests where none of the
authentication plugins could authenticate the client.

* **system:authenticated** group is automatically assigned to a user who was
authenticated successfully.

* **system:serviceaccounts** group encompasses all ServiceAccounts in the
system.

* **system:serviceaccounts:namespace** includes all ServiceAccounts in a
specific namespace.
