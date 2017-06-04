## Rubyでzaim API を使って遊んでみた

###できること

基本的な集計

* 総入力回数
* 総収入
* 総支出
* 総収益

月ごとの支出を一覧

* 累計
* 食費
* ガス料金
* 電気料金
* 水道料金
* ポケモンGO

ランキング

* カテゴリ別
* ジャンル別
* 支払先別

その他

* 各種ページから、Web版Zaimへのリンク

***

### git clone後にファイルを追加

Zaimアカウントとの連携情報をローカルに配置する

./api

```
{
  "key":"Zaimのコンシューマキー",
  "secret":"Zaimのシークレットキー",
  "oauth_token":"対象ユーザのOAuthToken",
  "oauth_secret":"対象ユーザのOAuthSecret"
}
```

***

### nginxの設定

```
user  root;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    #include /etc/nginx/conf.d/*.conf;

    proxy_buffer_size   512k;
    proxy_buffers   4 512k;
    proxy_busy_buffers_size   512k;

    upstream unicorn {
        server unix:/root/my-zaim/shared/tmp/unicorn.sock;
    }

    server {
    listen 3000;
    client_max_body_size 2M;
        server_name appname;
        root /root/my-zaim/app/public;
        access_log /root/my-zaim/logs/access.log;
        error_log /root/my-zaim/logs/error.log;
        try_files $uri/index.html $uri @unicorn;
        location @unicorn {
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $http_host;
            proxy_pass http://unicorn;
        }
    }
}
```

###備考

各種IDを決め打ちしたりしてるので汎用性はない模様
