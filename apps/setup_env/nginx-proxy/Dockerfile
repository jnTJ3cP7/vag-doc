FROM jwilder/nginx-proxy:alpine
RUN { \
      echo 'server_tokens off;'; \
      echo 'client_max_body_size 100g;'; \
      echo 'proxy_connect_timeout       6000;'; \
      echo 'proxy_send_timeout       6000;'; \
      echo 'proxy_read_timeout       6000;'; \
      echo 'send_timeout       6000;'; \
    } > /etc/nginx/conf.d/my_proxy.conf