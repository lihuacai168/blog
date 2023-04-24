#!/bin/bash

BLOG_DIR="$HOME/myblog"

if [ ! -d "$BLOG_DIR" ]; then
  mkdir "$BLOG_DIR"
  echo "文件夹 $BLOG_DIR 创建成功！"
else
  echo "文件夹 $BLOG_DIR 已存在！"
fi

cd "$BLOG_DIR"

read -p "请输入您的邮箱： " USER_EMAIL

DOCKER_COMPOSE_FILE="docker-compose.yml"

cat > "$DOCKER_COMPOSE_FILE" << EOL
version: "3"

services:
  vanblog:
    image: mereith/van-blog:latest
    restart: always
    environment:
      TZ: "Asia/Shanghai"
      EMAIL: "$USER_EMAIL"
    volumes:
      - \${PWD}/data/static:/app/static
      - \${PWD}/log:/var/log
      - \${PWD}/caddy/config:/root/.config/caddy
      - \${PWD}/caddy/data:/root/.local/share/caddy
    ports:
      - 1180:80
      # 禁止端口直接访问可以使用
      # 172.17.0.1是docker0网卡的ip
      # - "172.17.0.1:1180:80"
  mongo:
    image: mongo:4.4.16
    restart: always
    environment:
      TZ: "Asia/Shanghai"
    volumes:
      - \${PWD}/data/mongo:/data/db
EOL

echo "docker-compose.yml 文件创建成功！"

docker-compose up -d

PUBLIC_IP=$(curl -s ifconfig.me)

sleep 5

echo "博客已启动！请访问：http://${PUBLIC_IP}:1180"

