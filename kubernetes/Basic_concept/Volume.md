# Volume

Khi nhiều containers trong pod phải sử dụng chung một tài nguyên lưu trữ nào đó, thì phải sử dụng đến 1 volume chung để có thể  cùng truy suất vào được

## Volumetype

**emptyDir** —A simple empty directory used for storing transient data.

**hostPath** —Used for mounting directories from the worker node’s filesystem into the pod.

**gitRepo** —A volume initialized by checking out the contents of a Git repository.

**nfs** —An NFS share mounted into the pod.

**gcePersistentDisk**(Google Compute Engine Persistent Disk),**awsElastic-BlockStore** (Amazon Web Services Elastic Block Store Volume), **azureDisk** (Microsoft Azure Disk Volume)—Used for mounting cloud provider-specific
storage.

**cinder , cephfs , iscsi , flocker , glusterfs , quobyte , rbd , flexVolume , vsphere-Volume , photonPersistentDisk , scaleIO** —Used for mounting other types of
network storage.

**configMap , secret ,downwardAPI**—Special types of volumes used to expose certain Kubernetes resources and cluster information to the pod.

**persistentVolumeClaim**—A way to use a pre- or dynamically provisioned persistent storage.

## PersistentVolumes and PersistentVolumeClaims

### PersistentVolumes

PersistentVolumes là tạo ra 1 volume ảo với giá trị định sẵn như dung lượng, type, mức truy cập.... để pod có thể sử dụng

VD:

```md
    apiVersion: v1
    kind: PersistentVolume
    metadata:
    name: wordpress-pv
    labels:
        app: wordpress
    spec:
    capacity:
        storage: 5Gi
    accessModes:  
        - ReadWriteOnce
    hostPath:
        path: "/v1"  

```

### PersistentVolumeClaims

PersistentVolumeClaims là resource để có thể lấy về PV cho pod sử dụng, để có thể sử dụng PVC thì bắt buộc cần có PV trước đã.

VD:

```md
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wp-pv-claim
  labels:
    app: wordpress
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi

```

Liệt kê PV và PVC

```md
root@k8s-master:~# kubectl get pv
NAME           CAPACITY      ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                              STORAGECLASS   REASON   AGE
influx-pv      8Gi        RWO            Recycle          Bound    default/influxdb-data-influxdb-0                           2d
mysql-pv       5Gi        RWO            Recycle          Bound    default/wp-pv-claim                                        2d18h
wordpress-pv   5Gi        RWO            Retain           Bound    default/mysql-pv-claim                                     2d18h
root@k8s-master:~# kubectl get pvc
NAME                       STATUS   VOLUME         CAPACITY   ACCESS MODES   STORAGECLASS   AGE
influxdb-data-influxdb-0   Bound    influx-pv      8Gi        RWO                           2d1h
mysql-pv-claim             Bound    wordpress-pv   5Gi        RWO                           2d18h
wp-pv-claim                Bound    mysql-pv       5Gi        RWO                           2d18h

```
