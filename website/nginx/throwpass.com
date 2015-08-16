# This file goes in /etc/nginx/sites-available
# Create a symlink from /etc/nginx/sites-enabled/throwpass.com to this file

server {
  server_tokens off;
  add_header X-Frame-Options deny;
  add_header X-Content-Type-Options nosniff;
  add_header X-XSS-Protection "1; mode=block";
  add_header X-Permitted-Cross-Domain-Policies master-only;
  add_header Content-Security-Policy "default-src 'none'; script-src 'self'; img-src 'self' data:; style-src 'self'; connect-src 'self' wss://throwpass.com; report-uri /s/csp;";
  listen 443 default_server;
  listen [::]:443 default_server ipv6only=on;
  server_name  throwpass.com;

  root /var/www/html/public;

  ssl                  on;
  ssl_certificate      /etc/ssl/private/throwpass/chain.pem;
  ssl_certificate_key  /etc/ssl/private/throwpass/throwpass_com.pem;

  ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers "ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES256-SHA256:ECDHE-RSA-AES128-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA256:DHE-RSA-AES256-SHA384:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:DHE-RSA-DES-CBC3-SHA:ECDHE-RSA-CAMELLIA256-SHA:DHE-RSA-CAMELLIA256-SHA:ECEDH-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:ECDHE-RSA-SEED-SHA:DHE-RSA-SEED-SHA:ECDHE-RSA-CAMELLIA128-SHA:DHE-RSA-CAMELLIA128-SHA:AES256-GCM-SHA384:AES256-SHA256:AES128-GCM-SHA256:AES128-SHA256:SRP-RSA-AES-256-CBC-SHA:SRP-AES-256-CBC-SHA:AES256-SHA:SRP-RSA-AES-128-CBC-SHA:SRP-AES-128-CBC-SHA:AES128-SHA:CAMELLIA256-SHA:SRP-RSA-3DES-EDE-CBC-SHA:SRP-3DES-EDE-CBC-SHA:DES-CBC3-SHA:CAMELLIA128-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";
  ssl_prefer_server_ciphers   on;
  ssl_session_cache shared:SSL:10m;
  ssl_dhparam /etc/ssl/private/throwpass/dhparam.pem;

  ssl_stapling on;
  ssl_stapling_verify on;
  resolver 8.8.8.8 8.8.4.4 valid=300s;
  resolver_timeout 5s;
  ssl_trusted_certificate /etc/ssl/private/throwpass/chain.pem;


  proxy_connect_timeout 43200000;
  proxy_read_timeout 43200000;
  proxy_send_timeout 43200000;

  if ($ssl_protocol = "") {
    rewrite ^ https://$host$request_uri? permanent;
  }
  try_files $uri @proxysocket;

  location / {
    proxy_pass http://127.0.0.1:3000/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
  }
}

server {
  server_tokens off;
  add_header X-Frame-Options deny;
  add_header X-Content-Type-Options nosniff;
  add_header X-XSS-Protection "1; mode=block";
  add_header X-Permitted-Cross-Domain-Policies master-only;
  add_header Content-Security-Policy "default-src 'none'; script-src 'self'; img-src 'self' data:; style-src 'self'; connect-src 'self' wss://throwpass.com; report-uri /s/csp;";
  listen 443;
  listen [::]:443;
  server_name  www.throwpass.com;

  root /home/ubuntu/throwpass/website/public;

  ssl                  on;
  ssl_certificate      /etc/ssl/private/throwpass/chain.pem;
  ssl_certificate_key  /etc/ssl/private/throwpass/throwpass_com.pem;

  ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers "ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES256-SHA256:ECDHE-RSA-AES128-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA256:DHE-RSA-AES256-SHA384:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:DHE-RSA-DES-CBC3-SHA:ECDHE-RSA-CAMELLIA256-SHA:DHE-RSA-CAMELLIA256-SHA:ECEDH-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:ECDHE-RSA-SEED-SHA:DHE-RSA-SEED-SHA:ECDHE-RSA-CAMELLIA128-SHA:DHE-RSA-CAMELLIA128-SHA:AES256-GCM-SHA384:AES256-SHA256:AES128-GCM-SHA256:AES128-SHA256:SRP-RSA-AES-256-CBC-SHA:SRP-AES-256-CBC-SHA:AES256-SHA:SRP-RSA-AES-128-CBC-SHA:SRP-AES-128-CBC-SHA:AES128-SHA:CAMELLIA256-SHA:SRP-RSA-3DES-EDE-CBC-SHA:SRP-3DES-EDE-CBC-SHA:DES-CBC3-SHA:CAMELLIA128-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";
  ssl_prefer_server_ciphers   on;
  ssl_session_cache shared:SSL:10m;
  ssl_dhparam /etc/ssl/private/throwpass/dhparam.pem;

  ssl_stapling on;
  ssl_stapling_verify on;
  resolver 8.8.8.8 8.8.4.4 valid=300s;
  resolver_timeout 5s;
  ssl_trusted_certificate /etc/ssl/private/throwpass/chain.pem;

  add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";

  location / {
    error_page 301 /301.html;
    return 301 "https://throwpass.com$request_uri";
  }

  location = /301.html {
    # static
  }
}

server {
  server_tokens off;
  add_header X-Frame-Options deny;
  add_header X-Content-Type-Options nosniff;
  add_header X-XSS-Protection "1; mode=block";
  add_header X-Permitted-Cross-Domain-Policies master-only;
  add_header Content-Security-Policy "default-src 'none'; script-src 'self'; img-src 'self' data:; style-src 'self'; connect-src 'self' wss://throwpass.com; report-uri /s/csp;";
  charset utf-8;
  charset_types text/html text/xml text/plain text/vnd.wap.wml application/x-javascript application/rss+xml text/css;
  listen 80 default_server;
  listen [::]:80 default_server ipv6only=on;
  server_name throwpass.com;

  root /home/ubuntu/throwpass/website/public;

  location / {
    error_page 301 /301.html;
    return 301 "https://throwpass.com$request_uri";
  }

  location = /301.html {
    # static
  }
}

server {
  server_tokens off;
  add_header X-Frame-Options deny;
  add_header X-Content-Type-Options nosniff;
  add_header X-XSS-Protection "1; mode=block";
  add_header X-Permitted-Cross-Domain-Policies master-only;
  add_header Content-Security-Policy "default-src 'none'; script-src 'self'; img-src 'self' data:; style-src 'self'; connect-src 'self' wss://throwpass.com; report-uri /s/csp;";
  charset utf-8;
  charset_types text/html text/xml text/plain text/vnd.wap.wml application/x-javascript application/rss+xml text/css;
  listen 80;
  listen [::]:80;
  server_name www.throwpass.com;

  root /home/ubuntu/throwpass/website/public;

  location / {
    error_page 301 /301.html;
    return 301 "https://throwpass.com$request_uri";
  }

  location = /301.html {
    # static
  }
}
