## Giới thiệu
VictoriaMetrics là một hệ thống lưu trữ time-series với khả năng mở rộng cao và khả năng truy vấn mạnh mẽ, rất phù hợp cho việc sử dụng trong các hệ thống quản lý hiệu suất, giám sát, và theo dõi sự hoạt động của các ứng dụng và dịch vụ trên nền tảng đám mây.

## Cluster setup
https://git.paas.vn/BizFly-PaaS-Cloud/cloud-metrics-system/-/tree/master/ansible

Một cụm tối thiểu phải chứa các nút sau

một node vmstorage duy nhất với các flags -retentionPeriod và -storageDataPath
một node vminsert duy nhất với -storageNode=<vmstorage_host>
một node vmselect duy nhất với -storageNode=<vmstorage_host>
Chú ý

Nên chạy ít nhất hai nút cho mỗi dịch vụ nhằm mục đích có tính sẵn sàng cao. Trong trường hợp Cluster tiếp tục hoạt động khi một nút tạm thời không khả dụng và các nút còn lại có thể xử lý khối lượng công việc tăng lên. Node có thể tạm thời không khả dụng khi phần cứng cơ bản bị hỏng, trong quá trình nâng cấp phần mềm, di chuyển hoặc các tác vụ bảo trì khác.
Nên chạy nhiều node vmstorage nhỏ thay vì một vài node vmstorage lớn, Điều này làm giảm khối lượng công việc gia tăng trên các node vmstorage còn lại khi một số node vmstorage tạm thời không khả dụng.
Bộ cân bằng tải Load balancer http như vmauth hoặc nginx phải được đặt trước các node vminsert và vmselect. Nó phải chứa các config route sau theo chuẩn định dạng format url
Các yêu cầu bắt đầu bằng /insert phải được chuyển đến cổng 8480 trên các nút vminsert.
Các yêu cầu bắt đầu bằng /select phải được chuyển đến cổng 8481 trên các nút vmselect.
Các cổng có thể được thay đổi bằng cách đặt -httpListenAddr trên các node tương ứng.

## Policy

### Push metrics
    Push metrics cho thành phần nào ?
    Tên dịch vụ cần có để quy hoạch ?
    List ra các IP Node đi ra ?
    Sử dụng Protocol gì để đẩy ?  exp: influxdb or prometheus

write with prometheus protocol: http://127.0.0.1:8480/insert/2202/prometheus/api/v1/write 
write with influxdb protocol: http://127.0.0.1:8480/insert/2202/write 
## Cài đặt telegraf để thu thập metric trong vmagent và bắn log đến cụm victoria_metrics

select 8481 =>> http://service_host:10016/write    =>> telegraf
                http://service_host:10016/write/


## Relabel
- source_labels: [monitor]
  regex: ^service2$
  action: keep

- source_labels: [db]
  regex: ^service2$
  action: keep


## Get metrics by command curl endpoint

Get all labels
```
curl -X GET http://localhost:8481/select/2202/prometheus/api/v1/labels | jq
```

Insert value
```
curl 'http://10.3.54.126:10017/write?db=lms2' -u 'service2:ERm9remL9jVry31WBW5mpydZ' -d 'measurement,tag1=value1,tag2=value2 field1=123,field2=1.23'
```

select 
```
curl 10.3.54.126:8481/select/2202/prometheus/api/v1/series -d match[]='{db="service2"}' | jq
```

## Config telegraf-influxData to insert metrics
File config của telegraf được đặt tại /etc/telegraf/telegraf.conf

Install
```
sudo apt-get update && sudo apt-get install apt-transport-https

# Add the InfluxData key

wget -qO- https://repos.influxdata.com/influxdata-archive_compat.key | sudo apt-key add -
source /etc/os-release
test $VERSION_ID = "7" && echo "deb https://repos.influxdata.com/debian wheezy stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
test $VERSION_ID = "8" && echo "deb https://repos.influxdata.com/debian jessie stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
test $VERSION_ID = "9" && echo "deb https://repos.influxdata.com/debian stretch stable" | sudo tee /etc/apt/sources.list.d/influxdb.list

sudo apt-get update && sudo apt-get install telegraf
sudo service telegraf start
```

default configuration
```
telegraf config > telegraf.conf
```

### Telegraf metrics
telegraf metrics dựa trên data model của influxDB và bao gồm 4 thành phần chính:
    Measurement name: description and namespace for the metric
    Tags: key/value string pairs and usually used to identify the metric
    Fields: key/value pairs that are typed and usually contain the metric data.
    Timestamp: Date and time associated with the fields.

### telegraf input plugins
Telegraf input plugins are used with the InfluxData time series platform to collect metrics from the system, services, or third party APIs. All metrics are gathered from the inputs you enable and configure in the configuration file.

<a>https://docs.influxdata.com/telegraf/v1.9/plugins/inputs/</a>

#### Example
##### CPU
```
[[inputs.cpu]]
  ## Whether to report per-cpu stats or not
  percpu = true
  ## Whether to report total system cpu stats or not
  totalcpu = true
  ## If true, collect raw CPU time metrics.
  collect_cpu_time = false
  ## If true, compute and report the sum of all non-idle CPU states.
  report_active = false
  [inputs.cpu.tags]
    monitor = "service2"
```

##### MEM
```
[[inputs.mem]]
  [inputs.mem.tags]
    monitor = "service2"
```

=>> Thêm tags monitor = "service2" để tạo label.
Example output: 
```
mem,host=devops-test-metrics,monitor=service2 active=1050869760i,available=3612090368i,available_percent=87.51664771159713,buffered=52682752i,cached=2639147008i,commit_limit=2063659008i,committed_as=668098560i,dirty=315392i,free=1220722688i,high_free=0i,high_total=0i,huge_page_size=2097152i,huge_pages_free=0i,huge_pages_total=0i,inactive=1532379136i,low_free=0i,low_total=0i,mapped=165519360i,page_tables=2732032i,shared=1028096i,slab=275189760i,sreclaimable=206176256i,sunreclaim=69013504i,swap_cached=0i,swap_free=0i,swap_total=0i,total=4127318016i,used=214765568i,used_percent=5.203513932472316,vmalloc_chunk=0i,vmalloc_total=35184372087808i,vmalloc_used=11620352i,write_back=0i,write_back_tmp=0i 1681184906000000000
```

##### DISK

config
```
[[inputs.disk]]
  ## By default stats will be gathered for all mount points.
  ## Set mount_points will restrict the stats to only the specified mount points.
  # mount_points = ["/"]

  ## Ignore mount points by filesystem type.
  ignore_fs = ["tmpfs", "devtmpfs", "devfs", "overlay", "aufs", "squashfs"]
  [inputs.disk.tags]
    monitor = "service2"
```
Example output
```
disk,device=vda1,fstype=ext4,host=devops-test-metrics,mode=rw,monitor=service2,path=/ free=38173138944i,inodes_free=5055428i,inodes_total=5160960i,inodes_used=105532i,total=41442029568i,used=3252113408i,used_percent=7.850557868340877 1681184906000000000
```




### telegraf output plugins
Telegraf allows users to specify multiple output sinks in the configuration file.
<a>https://docs.influxdata.com/telegraf/v1.9/plugins/outputs/</a>

Example config output by influxDB protocol
```
[[outputs.influxdb]]
  ## The full HTTP or UDP URL for your InfluxDB instance.
  ##
  ## Multiple URLs can be specified for a single cluster, only ONE of the
  ## urls will be written to each interval.
  # urls = ["unix:///var/run/influxdb.sock"]
  # urls = ["udp://127.0.0.1:8089"]
  # urls = ["http://127.0.0.1:8086"]

  ## The target database for metrics; will be created as needed.
  # database = "telegraf"

  ## If true, no CREATE DATABASE queries will be sent.  Set to true when using
  ## Telegraf with a user without permissions to create databases or when the
  ## database already exists.
  # skip_database_creation = false

  ## Name of existing retention policy to write to.  Empty string writes to
  ## the default retention policy.  Only takes effect when using HTTP.
  # retention_policy = ""

  ## Write consistency (clusters only), can be: "any", "one", "quorum", "all".
  ## Only takes effect when using HTTP.
  # write_consistency = "any"

  ## Timeout for HTTP messages.
  # timeout = "5s"

  ## HTTP Basic Auth
  # username = "telegraf"
  # password = "metricsmetricsmetricsmetrics"

  ## HTTP User-Agent
  # user_agent = "telegraf"

  ## UDP payload size is the maximum packet size to send.
  # udp_payload = "512B"

  ## Optional TLS Config for use on HTTP connections.
  # tls_ca = "/etc/telegraf/ca.pem"
  # tls_cert = "/etc/telegraf/cert.pem"
  # tls_key = "/etc/telegraf/key.pem"
  ## Use TLS but skip chain & host verification
  # insecure_skip_verify = false

  ## HTTP Proxy override, if unset values the standard proxy environment
  ## variables are consulted to determine which proxy, if any, should be used.
  # http_proxy = "http://corporate.proxy:3128"

  ## Additional HTTP headers
  # http_headers = {"X-Special-Header" = "Special-Value"}

  ## HTTP Content-Encoding for write request body, can be set to "gzip" to
  ## compress body or "identity" to apply no encoding.
  # content_encoding = "identity"

  ## When true, Telegraf will output unsigned integers as unsigned values,
  ## i.e.: "42u".  You will need a version of InfluxDB supporting unsigned
  ## integer values.  Enabling this option will result in field type errors if
  ## existing data has been written.
  # influx_uint_support = false
```

output 
```
[[outputs.influxdb]]
  urls = ["http://10.3.54.126:10017"] # required
  database = "service2" # required
  retention_policy = ""
  write_consistency = "any"
  timeout = "10s"
  username = "service2"
  password = "ERm9remL9jVry31WBW5mpydZ"
```
### Telegraf aggregator plugins
Aggregators emit new aggregate metrics based on the metrics collected by the input plugins.

### Telegraf processor plugins
Processor plugins process metrics as they pass through and immediately emit results based on the values they process.

### Test output metrics
```
telegraf --config telegraf.conf --test
```

Example output
```
> mem,host=devops-test-metrics,monitor=service2 active=1050869760i,available=3612090368i,available_percent=87.51664771159713,buffered=52682752i,cached=2639147008i,commit_limit=2063659008i,committed_as=668098560i,dirty=315392i,free=1220722688i,high_free=0i,high_total=0i,huge_page_size=2097152i,huge_pages_free=0i,huge_pages_total=0i,inactive=1532379136i,low_free=0i,low_total=0i,mapped=165519360i,page_tables=2732032i,shared=1028096i,slab=275189760i,sreclaimable=206176256i,sunreclaim=69013504i,swap_cached=0i,swap_free=0i,swap_total=0i,total=4127318016i,used=214765568i,used_percent=5.203513932472316,vmalloc_chunk=0i,vmalloc_total=35184372087808i,vmalloc_used=11620352i,write_back=0i,write_back_tmp=0i 1681184906000000000
> disk,device=vda1,fstype=ext4,host=devops-test-metrics,mode=rw,monitor=service2,path=/ free=38173138944i,inodes_free=5055428i,inodes_total=5160960i,inodes_used=105532i,total=41442029568i,used=3252113408i,used_percent=7.850557868340877 1681184906000000000
> cpu,cpu=cpu0,host=devops-test-metrics,monitor=service2 usage_guest=0,usage_guest_nice=0,usage_idle=95.91836734305988,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=4.081632653227896,usage_user=0 1681184907000000000
> cpu,cpu=cpu1,host=devops-test-metrics,monitor=service2 usage_guest=0,usage_guest_nice=0,usage_idle=95.91836735445413,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=4.081632653712758,usage_user=0 1681184907000000000
> cpu,cpu=cpu-total,host=devops-test-metrics,monitor=service2 usage_guest=0,usage_guest_nice=0,usage_idle=96.93877551917403,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=3.0612244897353107,usage_user=0 1681184907000000000
root@devops-test-metrics:/etc/telegraf# telegraf --config /etc/telegraf/telegraf.conf --test
2023-04-11T03:52:26Z I! Loading config file: /etc/telegraf/telegraf.conf
> disk,device=vda1,fstype=ext4,host=devops-test-metrics,mode=rw,monitor=service2,path=/ free=38173134848i,inodes_free=5055428i,inodes_total=5160960i,inodes_used=105532i,total=41442029568i,used=3252117504i,used_percent=7.850567756029586 1681185147000000000
> mem,host=devops-test-metrics,monitor=service2 active=1056722944i,available=3607166976i,available_percent=87.39735978706808,buffered=53059584i,cached=2639134720i,commit_limit=2063659008i,committed_as=662138880i,dirty=0i,free=1215434752i,high_free=0i,high_total=0i,huge_page_size=2097152i,huge_pages_free=0i,huge_pages_total=0i,inactive=1532432384i,low_free=0i,low_total=0i,mapped=166621184i,page_tables=2662400i,shared=1028096i,slab=275365888i,sreclaimable=206163968i,sunreclaim=69201920i,swap_cached=0i,swap_free=0i,swap_total=0i,total=4127318016i,used=219688960i,used_percent=5.322801857001368,vmalloc_chunk=0i,vmalloc_total=35184372087808i,vmalloc_used=11636736i,write_back=0i,write_back_tmp=0i 1681185147000000000
> cpu,cpu=cpu0,host=devops-test-metrics,monitor=service2 usage_guest=0,usage_guest_nice=0,usage_idle=96.07843136896838,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=1.9607843137324836,usage_user=1.9607843136433174 1681185147000000000
> cpu,cpu=cpu1,host=devops-test-metrics,monitor=service2 usage_guest=0,usage_guest_nice=0,usage_idle=95.99999999627471,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=2.0000000000436557,usage_user=2.0000000000436557 1681185147000000000
> cpu,cpu=cpu-total,host=devops-test-metrics,monitor=service2 usage_guest=0,usage_guest_nice=0,usage_idle=97.02970296755811,usage_iowait=0,usage_irq=0,usage_nice=0,usage_softirq=0,usage_steal=0,usage_system=0.9900990099134721,usage_user=1.9801980198269442 1681185147000000000
```

