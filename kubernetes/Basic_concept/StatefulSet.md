# StatefulSet

Khi ta cần chạy những ứng dụng cần ổn định, ta sử dụng StatefulSets

So sánh với RS

Stateful Pods:

* Đối với Stateless app, thì kể cả khi ứng dụng đó bị chết thì có thể tạo mới mà không sao cả
* Đối với Statefull app, khi bị chết thì phải tạo ra mới giống y hệt cái cũ

StatefulSet đảm bảo rằng pod đó được schedule mà vẫn giữ nguyên định danh và trạng thái, đồng thời giúp dễ dàng scale

Khi được tạo bởi StatefulSet, tên của pod sẽ đoán trước được
VD:

```md
root@k8s-master:~# kubectl get statefulsets.apps
NAME       READY   AGE
influxdb   1/1     2d1h
root@k8s-master:~# kubectl get pod
NAME                               READY   STATUS    RESTARTS   AGE
grafana-cc4cc59bb-tvggh            1/1     Running   6          2d1h
influxdb-0                         1/1     Running   7          2d1h
```

Đồng thời thì StatefulSet cũng tạo ra PV đi cùng nó. Khi scale down thì PVC giữ nguyên, chỉ có pod bị xóa, khi scale up lại thì tạo ra 1 pod y hệt pod đã bị xóa
