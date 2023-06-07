## Configure automatic Envoy Proxy Injection
kubectl label namespace default istio-injection=enable

## Test curl 
curl http://10.3.52.97:30582/ -H "Host:customer.test"


# test 
curl "http://$GATEWAY_URL/
curl http://10.5.91.89:30096