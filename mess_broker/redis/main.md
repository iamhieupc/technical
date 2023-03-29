## Giới thiệu
Redis là 1 open-source in-memory, No sql, key/value, được lưu chủ yếu dưới dạng cache vì dữ liệu được lưu thẳng trên memory thay vì trên ổ đĩa ssd ===>> Nói chung redis tốc độ, tin cậy

Nó có thể hỗ trợ nhiều kiểu dữ liệu như: strings, hashes, lists, sets, sorted.

redis-cli sủ dụng kết nối tcp đơn giản để kết nối đến redis

## Install Redis
Done
Check is installed redis
```
redis-cli --version
```

Check ping redis
```
redis-cli -h localhost -p 6379 ping
```

## Redis cli
show info server
```
info server
```

set value for key
```
set name "hieupc"
```

get value for key
```
get name
```

Có thể sử dụng namespace cùng với key
```
set name:namespace "hieupc"
```

get all key
```
keys *
```

get all children key of a key
```
keys *name*
```

delete key
```
del key1 key2
```

delete all key
```
flushdb
```

delete all key in every db
```
flushall
```

Bình thường redis sẽ có 16 database, Muốn chọn 1 database
```
select 15
```

Muốn swap data từ 1 database sang database khác
```
swapdb 6 8
```

Muốn migrate 1 key từ database hiện tại sang 1 database khác
```
migrate 203.0.113.0 6379 key_1 7 8000
```

Đổi tên key
```
rename old_key new_key
```


## Setup master slave redis
https://rtfm.co.ua/en/redis-replication-part-2-master-slave-replication-and-redis-sentinel/?fbclid=IwAR32yZkyYak3pec5d-JacaueMyme8UJH9HIGemRhYE0CYGjbQ343f0IYfxA