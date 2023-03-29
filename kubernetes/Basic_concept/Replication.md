# Replication

## ReplicationController

ReplicationController là resource của k8s đảm bảo pod sẽ luôn chạy, trong trường hợp pod không chạy, bị mất vì lý do gì đó, RC sẽ tự thay thế pod đó.

Đối với ReplicationController sẽ có giá trị `Replicas` trong file `.yaml`, giá trị này ứng với số pod được tạo ra bởi RC. Nếu muốn tăng, giảm số lượng thì có thể edit RC.

Để xóa những pod tạo bơi RC, ta phải xóa RC đó đi không RC sẽ tiếp tục tạo lại pod mới.

## ReplicaSet

Tương tự như RC, RS cũng có chức năng tương tự, nhưng với ưu điểm là RC chỉ có thể match được pod với label có giá trị nhất định, trong khi RS có thể match được nhiều label và coi như là 1 nhóm

```md
root@k8s-master:~# kubectl get rs
NAME                         DESIRED   CURRENT   READY   AGE
grafana-cc4cc59bb            1         1         1       2d
wordpress-5bbd7fd785         1         1         1       2d18h
wordpress-mysql-85ff59475f   1         1         1       2d18h
```

## DaemonSet

Trong khi RC và RS tạo pod theo yêu cầu nhưng không quan tâm đến vị trí pod được tạo thì DS sẽ tạo pod ở trên node khác nhau.
