## Giới thiệu
Nginx là 1 open-source linux application cho web server, như một reverse proxy server nhằm mục đích chuyển hướng traffic đến specific servers.

## Config file nginx

```
# redirect to https when client connect to http protocol
server {
    listen       80;
    server_name  hn-staging2.bizflycloud.vn;
    return 301 https://$host$request_uri;
}   

server {
  listen      443 ssl;
    server_name hn-staging2.bizflycloud.vn;

    # access_log thì lưu trong /var/log/nginx/hn-staging2.bizflycloud.vn.ssl.log
    access_log   /var/log/nginx/hn-staging2.bizflycloud.vn.ssl.log cls_log;   

    error_log    /var/log/nginx/hn-staging2.bizflycloud.vn.error.ssl.log;

    # include content ssl trong file bên dưới
    include /etc/nginx/custom/ssl_for_bizfly.conf;

    # custom error
    error_page 404 /404.svg;
    location = /404.svg {
            root    /etc/nginx/custom/error_pages/;
            allow   all;
     }

    error_page 505 /505.svg;
    location = /505.svg {
            root    /etc/nginx/custom/error_pages/;
            allow   all;
     }

    error_page 500 502 503 504 /5xx.svg;
    location = /5xx.svg {
            root    /etc/nginx/custom/error_pages/;
            allow   all;
     }

  location /api/serverless-backend/ {
        fastcgi_param           REMOTE_ADDR     $http_x_real_ip;
        add_header              Strict-Transport-Security "max-age=0;";  sử dụng https cho tất cả các request 

        ##  rewrite from /api/serverless-backend/ to / in service
        rewrite                 /api/serverless-backend/(.*) /$1  break; 


        proxy_pass              http://new_k8s_staging/;

        proxy_next_upstream     error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect          default;
        proxy_buffering         off;    ===>> không có buffer từ backend server

        # Set header có host đến server
        proxy_set_header        Host            serverlesss-backend.staging.bizflycloud.vn;

        # X-Real-IP tới ip address của client
        proxy_set_header        X-Real-IP       $remote_addr;
        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version      1.1;
        proxy_set_header        Upgrade         $http_upgrade;
        proxy_set_header        Connection      "upgrade";

        # Set timeout for establishing a connect to upstream server
        proxy_connect_timeout   600;

        # proxy_set_header        X-Forwarded-Proto $scheme;
        proxy_set_header        X-Origin-Host            $host;
        proxy_set_header        X-Origin-Path   $request_uri; 
    }
}     
```

#### rewrite in nginx
Được sử dụng để modify or rewrite  các request url trước khi xử lý các request.

##### Syntax
syntax1: rewrite regex replacement [flag];
=>> rewrite ^/old-uri/(.*)$ /new-uri/$1 permanent;
Cái này thì nó thay đổi old-uri thành new-uri và giữ nguyên đằng sau

syntax2: rewrite (before|after) string replacement [flag];
==>> rewrite before /old-path/ /new-path/;

##### Các cờ trong rewrite
last: Stops the processing of the current set of rewrite directives and restarts the processing with a new request URI.
break: Stops the processing of the current set of rewrite directives and passes the current request URI to the next processing phase.
redirect: Performs a 302 temporary redirect to the specified URI.
permanent: Performs a 301 permanent redirect to the specified URI.

Sự khác nhau giữa last và break:
  last: rewrite xong thì đổi url
  break: rewrite xong thì ko đổi url
