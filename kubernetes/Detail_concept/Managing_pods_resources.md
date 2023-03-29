# Managing pods computational resources

## Yêu cầu tài nguyên cho container

### Tạo yêu cầu tài nguyên

Để tạo yêu cầu tài nguyên:

```md
resources:
  requests:
    cpu: 200m
    memory: 10Mi
```

Như trên, pod sử dụng 200millicore (1/5 của CPu core)

### Giới hạn tài nguyên cho container

```md
resources:
  limits:
    cpu: 1
    memory: 20Mi
```

Tạo LimitRange

```md
spec:
  limits:
    - type: Pod
      min:
        cpu: 50m
        memory: 5Mi
      max:
        cpu: 1
        memory: 1Gi
      - type: Container
      defaultRequest:
        cpu: 100m
        memory: 10Mi
      default:
        cpu: 200m
        memory: 100Mi
      min:
        cpu: 50m
        memory: 5Mi
      max:
        cpu: 1
        memory: 1Gi
      maxLimitRequestRatio:
        cpu: 4
        memory: 10
```

Tạo resource quota cho NS

```md
apiVersion: v1
kind: ResourceQuota
metadata:
  name: cpu-and-mem
  spec:
    hard:
      requests.cpu: 400m
      requests.memory: 200Mi
      limits.cpu: 600m
      limits.memory: 500Mi
```

## Theo dõi tài nguyên sử dụng

Để theo dõi tài nguyên sử dụng trong k8s, ta có thể dùng heapster

Để hiện thị mức sử dụng cho node, pod, ta sử dụng

```md
kubectl top node
NAME        CPU(cores)  CPU%    MEMORY(bytes) MEMORY%
minikube    170m    8%      556Mi   27%
```

```md
root@k8s-master:~# kubectl top pod
NAME                               CPU(cores)   MEMORY(bytes)
grafana-cc4cc59bb-tvggh            3m           27Mi
influxdb-0                         4m           96Mi
wordpress-5bbd7fd785-n7lgf         0m           39Mi
wordpress-mysql-85ff59475f-2tltf   0m           473Mi
```

Ta có thể sử dụng influxDB để lưu trữ thông tin monitor và grafana để quản lý, dựng biểu đồ, tạo cảnh báo cho k8s

![grafana](https://raw.githubusercontent.com/lmq1999/Mytest/master/Screenshot%20from%202020-06-12%2011-06-13.png)

