# Chuẩn bị cài đặt kubernetes 1.16 (the hard way)

## Chuẩn bị VM

### Mô hình

![vm](https://raw.githubusercontent.com/lmq1999/123/master/k8s-hw-model.png)

Chuẩn bị IP:

|  Name             | CIDR                  |
|---                |---                    |
|   VM              |   192.168.122.0/24    |
|   POD             |   10.200.0.0/16       |
|  Service          |   10.32.0.0/16        |

### Cấu hình file host

```sh
cat << EOF | sudo tee /etc/hosts
192.168.122.15  k8s-master
192.168.122.131 k8s-worker1
192.168.122.206 k8s-worker2
EOF
```

### Cài đặt các gói cần thiết

Trên node **k8s-master**

* Tạo thư mục để chứa file cấu hình là TLS certs

    ```sh
    mkdir ~/k8s-the-hard-way
    cd ~/k8s-the-hard-way
    ```

* Cài **kubectl** bản 1.16

    ```sh
    #Tải về từ source
    curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.16.0/bin/linux/amd64/kubectl
    # Cho phép execute
    chmod +x kubectl
    # Chuyển vào thư mục bin để chạy
    sudo mv kubectl /usr/local/bin/
    ```

    Kiểm tra phiên bản:

    ```sh
    root@k8s-master:~# kubectl version --client
    Client Version: version.Info{Major:"1", Minor:"16", GitVersion:"v1.16.0", GitCommit:"2bd9643cee5b3b3a5ecbd3af49d09018f0773c77", GitTreeState:"clean", BuildDate:"2019-09-18T14:36:53Z", GoVersion:"go1.12.9", Compiler:"gc", Platform:"linux/amd64"}
    ```
