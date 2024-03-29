server {
    listen 80;
    server_name trafgen.load.wazo.io;

    location / {
        proxy_pass https://backend;
        proxy_ssl_verify off;
        proxy_connect_timeout 60s;
        proxy_read_timeout 600s;
    }
}
