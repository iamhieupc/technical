# Service (svc)

* Các Pod  không đảm bảo về địa chỉ ip luôn cố định khiến cho việc giao tiếp giữa các microservice trở nên khó khăn.
* K8s giới thiệu về một serices, nó là một lớp nằm trên một số nhóm Pod. Nó được được gắn địa chỉ IP tĩnh và có thể trỏ domain vào dịch vụ này. Tại đây chúng ta có thể thực hiện cân bằng tải...

![svc](https://images.viblo.asia/3d693a60-72c5-42cc-9117-4b66ce3e66f7.png).

## Kết nối từ client bên ngoài vào pod

Để kết nối client bên ngoài vào port ta sử dụng `NodePort` type service

VD

```md
root@k8s-master:~# cat wordpress-deployment.yaml
apiVersion: v1
kind: Service
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  ports:
    - port: 80
  selector:
    app: wordpress
    tier: frontend
  type: NodePort
---

```

Liệt kê service:

```md
root@k8s-master:~# kubectl get svc
NAME              TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
grafana           NodePort       10.104.13.130   <none>        80:30560/TCP        2d
influxdb          ClusterIP      10.96.241.247   <none>        8086/TCP,8088/TCP   2d
kubernetes        ClusterIP      10.96.0.1       <none>        443/TCP             2d18h
wordpress         NodePort       10.104.90.82    <none>        80:31569/TCP        2d18h
wordpress-mysql   ClusterIP      None            <none>        3306/TCP            2d18h
```
