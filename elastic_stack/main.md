## Setup
https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elastic-stack-on-ubuntu-20-04


## Query
curl -XPOST -H "Content-Type: application/json" http://localhost:9200/{jobdata}/_search -d '{
  "query": {
    "match": {
      "client_name": "vuong"
    }
  }
}'

