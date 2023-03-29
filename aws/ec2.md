## Giới thiệu

EC2 là 1 service của AWS (Elastic Compute Cloud) cung cấp server cloud trên aws

## Một số tính năng cảu EC2
1, Là 1 môi trường ảo 
2, Amazon Machine Images (AMIs) là 1 package được đóng gói để tạo 1 resource ec2 (bao gồm OS và softwares)
3, Cài đặt CPU, Memory, Storage and Networking 
4, Sử dụng login for resource bằng việc dử dụng key pairs (AWS lưu public key, user lưu private key)
5, Firewall in ec2: Có thể sử dụng security groups
6, Có thể tạo tags và gán cho ec2
7, Có thể tạo các mạng ảo VPC và gán ec2 vào trong VPC đó
8, Có thể tạo Elastic IPs, Nó là 1 ip public và cố định link đến server. Để khi stop ec2 instance thì sẽ ko thay đổi ip address