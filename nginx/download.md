server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;

        server_name _;

        location /dev/ {
                #alias /root/monitor-agent/artifacts/;
                alias /var/www/html/dev/;
                #auth_basic "Restricted Content";
                #auth_basic_user_file /etc/nginx/basic-auth/.htpasswd;
                allow 10.22.0.34;
                allow 10.22.0.21;
                deny all;
                try_files $uri $uri/ /dev/install_agent.sh;
        }

        location /release/ {
                #alias /root/monitor-agent/artifacts/;
                alias /var/www/html/release/;
        }

}
