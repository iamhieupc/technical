# ConfigMaps and Secrets

## ConfigMaps

Kubernetes cho phép tách biệt lựa chọn cấu hình ra đối tượng riêng biệt gọi là ConfigMaps, COnfigmaps sẽ là bản ánh xạ cặp khóa giá trị.

Ứng dụng không cần thiết phải đọc trực tiếp được configmap. Những giá rị cần thiết sẽ được ánh xạ đến containers dưới dạng biến mối trường hoặc file trong volumes

VD:

```md
root@k8s-master:~# kubectl get configmaps
NAME           DATA   AGE
grafana        1      2d
grafana-test   1      2d
influxdb       1      2d
```

## Secret

Secret gần giống như configmap nhưng khác ở chỗ, Seccrets đảm bảo an toàn bằng cách chỉ phát cho những node có pod mà cần truy cập và secret đó.

Secret sẽ được lưu trữ vào memory, không được ghi trên ổ cứng

Dùng ConfigMaps để chứa dữ liệu bình thường.

Dùng Secret khi cần chứa dữ liệu nhạy cảm. Nếu như có cả dữ liệu nhạy cảm và bình thường thì nên sử dụng Secret

VD:

```md
root@k8s-master:~# kubectl get secret
NAME                             TYPE                                  DATA   AGE
default-token-n86gz              kubernetes.io/service-account-token   3      2d19h
grafana                          Opaque                                3      2d
grafana-test-token-rhnks         kubernetes.io/service-account-token   3      2d
grafana-token-k8h8b              kubernetes.io/service-account-token   3      2d
influxdb-token-wkrh4             kubernetes.io/service-account-token   3      2d
mysql-pass-c57bb4t7mf            Opaque                                1      2d18h
sh.helm.release.v1.grafana.v1    helm.sh/release.v1                    1      2d
sh.helm.release.v1.influxdb.v1   helm.sh/release.v1                    1      2d
```
