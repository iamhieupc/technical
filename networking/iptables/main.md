Các bảng trong Iptables:

- FILTER: đây là bảng mặc định được sử dụng để lọc các gói và bao gồm các chuỗi như: INPUT, OUTPUT và FORWARD.
- NAT: bản có liên quan đến việc dịch địa chỉ mạng.
- MANGLE: bản được sử dụng để thay đổi các gói chuyên biệt
- RAW: dùng để cấu hình không theo dõi các kết nối
- SECURITY: thông thường, SELinux sử dụng để thiết lập chính sách bảo mật.

Target trong Iptables:

- ACCEPT: chấp nhận gói tin và gói được phép đi vào hệ thống.
- DROP: loại bỏ gói tin
- REJECT: loại bỏ gói tin và chuyển hướng xử lý đến một bảng khác.
- LOG: chấp nhận gói tin và ghi lại nhật ký.

Chain trong Iptables:

- INPUT: sử dụng để điều khiển các gói tin đến điểm đích hoặc máy chủ. Bạn có thể cho phép hoặc chặn các kết nối bằng nhiều cách như: địa chỉ IP, cổng hoặc giao thức.
- FORWARD: máy chủ sẽ trở thành trung gian để chuyển tiếp các gói đến nơi khác.
- OUTPUT: sử dụng để lọc các gói tin đi ra từ phía máy chủ của bạn.

Một số lệnh hay dùng trong Iptables:

**Cho phép truy cập vào web server qua port mặc định là 80 và 443**

iptables -I INPUT -p tcp -m tcp - -dport 80 -j ACCEPT

iptables -I INPUT -p tcp -m tcp - -dport 443 -j ACCEPT

Trong đó: -I: insert rule

-p: protocol

-m: match extension

-dport: cổng

-j: target for rule: accept/drop/reject/log

**Xóa tất cả các rule:**

iptables -F

Xóa rule ở dòng thứ 2:

iptables -D INPUT 2

Basic syntax:

- **`A --append`** – Add a rule to a chain (at the end).
- **`C --check`** – Look for a rule that matches the chain’s requirements.
- **`D --delete`** – Remove specified rules from a chain.
- **`F --flush`** – Remove all rules.
- **`I --insert`** – Add a rule to a chain at a given position.
- **`L --list`** – Show all rules in a chain.
- **`N -new-chain`** – Create a new chain.
- **`v --verbose`** – Show more information when using a list option.
- **`X --delete-chain`** – Delete the provided chain.

accept address specific ip address;

iptables -A INPUT -s 10.22.0.1 -j ACCEPT

reject traffic trong khoảng ip:

sudo iptables -A INPUT -m iprange --src-range 192.168.0.1-192.168.0.255 -j REJECT

chặn traffic đi vào google.com

sudo iptables -A OUTPUT  -d [google.com](http://google.com) -j DROP

Mở cổng SSH (mặc định là cổng 22) cho các kết nối đến từ bastion host:

iptables -A INPUT -p tcp —dport 22 -s 10.22.0.247 -j ACCEPT

iptables -A INPUT -p tcp —dport 22 -j DROP

Mở cổng SSH để có thể kết nối từ máy chủ bastion đến các máy chủ trong dải mạng:

iptables -A OUTPUT -p tcp —sport 22 -d 10.22.0.0/22 -j ACCEPT 

Các gói tin từ mạng nội bộ (192.168.1.0/24) khi ra khỏi máy chủ qua giao diện **`eth0`** sẽ có địa chỉ nguồn được thay đổi thành **`203.0.113.1`**.

iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o eth0 -j SNAT —to 203.0.113.1

Mục đích: Khi có một kết nối đến cổng 80, địa chỉ đích của gói tin sẽ được thay đổi thành 192.168.1.10 và cổng 8080.

iptables -t nat -A PREROUTING -p tcp —dport 80 -j DNAT —to 192.168.1.10:8080

Mục đích: Tất cả gói tin HTTP đến cổng 80 sẽ được chuyển hướng (redirect) đến cổng 8080, nơi mà có thể chạy một proxy server.

iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080

Mục đích: Khi có kết nối đến cổng 443, địa chỉ đích của gói tin sẽ được thay đổi thành 192.168.1.20 và cổng 8443.

iptables -t nat -A PREROUTING -p tcp —dport 443 -j DNAT —to 192.168.1.20:8443

Mục đích: Chỉ cho phép kết nối SSH từ địa chỉ IP 192.168.1.2 và chặn tất cả các kết nối SSH khác.

iptables -A INPUT -p tcp —dport 22 -s 192.168.1.2 -j ACCEPT

iptables -A INPUT -p tcp —dport 22 -j DROP

Mục đích: Chặn các yêu cầu ping đến máy chủ.

iptables -A INPUT -p icmp —icmp-type echo-request -j DROP

Mục đích: Chặn tất cả các kết nối từ máy chủ đến địa chỉ IP 203.0.113.1.

iptables -A OUTPUT -d 203.0.113.1 -j DROP

Mục đích: Chặn mọi truy cập HTTP từ máy chủ.

iptables -A OUTPUT -p tcp --dport 80 -j REJECT

Mục đích: Cho phép truy cập HTTPS từ máy chủ.

iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT