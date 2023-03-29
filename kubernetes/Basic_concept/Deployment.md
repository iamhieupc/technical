# Deployment

Deployment là resource cấp cao, dùng để triển khai và cập nhật các ứng dụng thông qua RC hoặc RS.

Khi tạo ra Reployment, RS sẽ được tạo và quản lý pod thông quả RS

## Nâng cấp deployements

Khi update sử dụng RC, chúng phải ta phải chạy lệnh update, đặt tên mới cho RC. Sau đó K8s sẽ thay thế pod cũ bằng những pod mới. Trong lúc đó thì terminal phải luôn mở đợi cho `kubectl` thực hiện xong update

Đối với Deployment, ta chỉ cần thay đổi nhỏ template được định nghĩa trong Deployment và K8s sẽ tự động thực hiện việc cần thiết để có hệ thống theo yêu cầu đặt ra.

Đồng thời deployment cũng hộ trợ việc rollback lại version cũ trong trường hợp version mới gặp vấn đề

Deployment cũng lưu những phiên bản cũ và chặn những phiên bản lỗi để không rollback lại đó.
