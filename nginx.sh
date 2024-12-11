#!/bin/bash
sudo apt install curl gnupg2 ca-certificates lsb-release debian-archive-keyring

curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg


echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/debian `lsb_release -cs` nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list

echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
    | sudo tee /etc/apt/preferences.d/99nginx

sudo apt update

sudo apt install nginx

nginx -v

cat > /etc/nginx/nginx.conf << "EOF"
user  root;
worker_processes  auto;
  # error_log  /etc/nginx/error.log warn;
  # pid    /var/run/nginx.pid;
events {
    worker_connections  1024;
    }
http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';
  # access_log  /etc/nginx/access.log  main;
    client_max_body_size 0;

    sendfile       on;
    tcp_nopush     on;
    keepalive_timeout  65;
  # gzip  on;
server {
    listen       80;
    return 301 https://$host$request_uri;
     }
   include /etc/nginx/conf.d/*.conf;
    }
EOF


cat > /etc/nginx/conf.d/default.conf << "EOF"
server {
    listen 443 ssl;
    ssl_certificate     /etc/key/server.crt;
    ssl_certificate_key /etc/key/server.key;
    server_name  *.ilmz.net;


location / {
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto $scheme;
  proxy_set_header Host $http_host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header Range $http_range;
  proxy_set_header If-Range $http_if_range;
  proxy_redirect off;
  proxy_pass http://127.0.0.1:8081;
# client_max_body_size 20000m;
  }
}
EOF