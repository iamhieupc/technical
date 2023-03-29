# Role-based access control

Quy tắc ủy quyền của RBAC được cấu hình thông qua 4 resources, có thể chia thành 2 nhóm

* **Roles** and **ClusterRoles**, which specify which verbs can be performed on which
resources.
* **RoleBindings** and **ClusterRoleBindings**, which bind the above roles to specific
users, groups, or ServiceAccounts.
  * Nhóm Roles xác định xem có thể làm những gì
  * Nhóm Binding xác định xem ai có thể lam được.

* **Role** và **ClusterRoles** là tài nguyên trong namespace
* **RoleBindings** và **ClusterRoleBindings** là tài nguyen của cluster

## Role và RoleBindings

Role là tài nguyên xác định xem hành động nào có thể thực hiên trên resources nào

```md
root@k8s-master:~# kubectl get roles.rbac.authorization.k8s.io
NAME           CREATED AT
grafana        2020-06-09T03:18:01Z
grafana-test   2020-06-09T03:18:01Z
```

Role định nghĩa hành động có thể thực hiện, nhưng không nói xem ai sẽ thực hiện được nó. Để làm điều nào chúng ta phải gán role và đối tượng, có thể là user, SA, group, ....

Có resource để làm điều đó là RoleBindings.

```md
NAME           ROLE                AGE
grafana        Role/grafana        2d23h
grafana-test   Role/grafana-test   2d23h
```

Rolebinding cho phép SA từ namespace khác

## ClusterRoles và ClusterRoleBindings

Như đã nói ở trên, **Role** và **ClusterRoles** là tài nguyên trong namespace còn **RoleBindings** và **ClusterRoleBindings** là tài nguyen của cluster, chúng không có namespace

Vì một số tài nguyên như PV không nằm trong namespace nào cả, nên không thể dùng **Role và Rolebinding** để có quyền tương tác với resource đó. Chúng ta cần **ClusterRoles và ClusterRoleBindings**
