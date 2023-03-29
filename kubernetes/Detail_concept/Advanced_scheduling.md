# Advanced scheduling

## Sử dụng taints và tolerations

Taint và tolerations dùng để giới hạn pod chỉ được tạo trên node nhất định. Pod chỉ được tạo trên node đó khi có tolerates được nodes taint

VD:

```md
Roles:              master                                                                                                                    [42/114]
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=k8s-master
                    kubernetes.io/os=linux
                    node-role.kubernetes.io/master=
Annotations:        flannel.alpha.coreos.com/backend-data: {"VtepMAC":"56:b8:fa:47:ad:29"}
                    flannel.alpha.coreos.com/backend-type: vxlan
                    flannel.alpha.coreos.com/kube-subnet-manager: true
                    flannel.alpha.coreos.com/public-ip: 192.168.122.146
                    kubeadm.alpha.kubernetes.io/cri-socket: /var/run/dockershim.sock
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Mon, 08 Jun 2020 09:06:04 +0000
Taints:             node-role.kubernetes.io/master:NoSchedule
Unschedulable:      false

```

Ta có thấy thấy Taints có giá trị là:
`<key>=<value>:<effect>`

Hiển thị tolerant:

```md
Tolerations:
                 CriticalAddonsOnly
                 node-role.kubernetes.io/master:NoSchedule
                 node.kubernetes.io/disk-pressure:NoSchedule
                 node.kubernetes.io/memory-pressure:NoSchedule
                 node.kubernetes.io/network-unavailable:NoSchedule
                 node.kubernetes.io/not-ready:NoExecute
                 node.kubernetes.io/pid-pressure:NoSchedule
                 node.kubernetes.io/unreachable:NoExecute
                 node.kubernetes.io/unschedulable:NoSchedule
```

Ta có thể thấy, pod được schedule vào master nhờ có tolerate taint đó.

Mỗi taint có hiệu ứng đi kèm với nó:

* NoSchedule , which means pods won’t be scheduled to the node if they don’t tol-
erate the taint.

* PreferNoSchedule is a soft version of NoSchedule , meaning the scheduler will
try to avoid scheduling the pod to the node, but will schedule it to the node if it
can’t schedule it somewhere else.

* NoExecute , unlike NoSchedule and PreferNoSchedule that only affect schedul-
ing, also affects pods already running on the node. If you add a NoExecute taint
to a node, pods that are already running on that node and don’t tolerate the
NoExecute taint will be evicted from the node.

### Tạo custom taint cho node

```md
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: prod
    spec:
    replicas: 5
      template:
        spec:
        ...
          tolerations:
          - key: node-type
                Operator: Equal
                value: production
                effect: NoSchedule
```

## Sử dụng node affinity để kéo pod về những node nhất định

```md
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=k8s-worker1
                    kubernetes.io/os=linux

```

Đối với selector

```md
apiVersion: v1
kind: Pod
metadata:
  name: kubia-gpu
spec:
  nodeSelector:
    gpu: "true"
```

Thì với label này chỉ có thể deploy với node label là `gpu:true`

Nhưng đối với node Affinity

```md
apiVersion: v1
kind: Pod
metadata:
  name: kubia-gpu
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: gpu
            operator: In
            values:
            - "true"
```

Ta thấy nodeAffinity có lệnh:

* requiredDuringScheduling... means the rules defined under this field spec-
ify the labels the node must have for the pod to be scheduled to the node.

* IgnoredDuringExecution means the rules defined under the field don’t
affect pods already executing on the node.

Ngoài ra còn có thể có lệnh khác như:

* preferredDuringScheduling:

* IgnoredDuringExecution:

Trong trường hợp này sẽ ưu tiên schedule vào những node theo yêu cầu hơn, chứ không còn bắt buộc

Ngoài ra còn có thể sử dụng `podAntiAffinity:` để schelude pod lên node khác nhau theo yêu cầu.

