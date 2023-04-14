### Giới thiệu
Ansible là 1 opensource, sử dụng cli command để automation configuration, được phát triển bởi RedHat

### Cách sử dụng

#### deploy service to k8s
helm install name_service ./path_name --value values.yaml -n staging-dns

#### uninstall service
helm uninstall name_service -n staging-dns
