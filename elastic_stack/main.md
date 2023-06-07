## Explore
Theo như tìm hiểu thì Elastic Stack là 1 nhóm các sản phẩm từ Elastic được thiết kế để người dùng lấy được data từ bất kì một kiểu mã nguồn nào và trong bất kì 1 format nào, có thể search, phân tích những data một cách real time.

Các công nghệ sử dụng:
  - Elastic Search
  - Kibana
  - Logstash
  - Beats

Chức năng của các công nghệ
  - Elastic Search: Là một công nghệ có thể phân tán, real-time search và phân tích các dữ liệu, cung cấp tốc độ việc đánh index và khả năng tìm kiếm, query tự do.
  - Logstash: Logstash là 1 quy trình xủ lý data từ nhiều source, dịch chuyển nó và push dât lên Elasticsearch bằng viêc đánh index. Nó cỏ thể sử lý log files, system metrics, event data và các kiểu dữ liệu cấu trúc hoặc không có cấu trúc khác. Logstash hỗ trợ đa dạng các plugins như: input, fileter, output cho việc thu thập dữ liệu và chuyển dữ liệu
  - Kibana: KIbana là 1 dashboard để hiển thị các dữ liệu của Elastic, nó cung cấp biểu đồ để phân tích các dữ liệu được lưu trên elasticsearch. Có thể tạo chart, dasboard, map để  nhận được ý nghĩa của dữ liệu
  - Beats: Là 1 nơi dịch chuyển dữ liệ đến Elasticsearch hoặc Logstash. Chúng được thiết kế cho việc thu thập các logs hệ thống (Filebeat), metric data (Metricbeat), network data (Packetbeat) và audit data (Auditbeat)

## Setup
https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elastic-stack-on-ubuntu-20-04


## Query
curl -XPOST -H "Content-Type: application/json" http://localhost:9200/jobdata/_search -d '{
  "query": {
    "match": {
      "client_name": "vuong"
    }
  }
}'

