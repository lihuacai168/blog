#!/bin/bash

#!/bin/bash

BLOG_DIR="$HOME/myblog"

if [ ! -d "$BLOG_DIR" ]; then
    mkdir -p "$BLOG_DIR"
    echo "目录 $BLOG_DIR 已创建。"
else
    echo "目录 $BLOG_DIR 已存在。"

    while true; do
        read -p "请输入新的目录名称，默认是在当前用户下目录，需要写名称，不要写完整路径" new_dir_name
        NEW_BLOG_DIR="$HOME/$new_dir_name"

        if [ ! -d "$NEW_BLOG_DIR" ]; then
            mkdir -p "$NEW_BLOG_DIR"
            echo "新的目录 $NEW_BLOG_DIR 已创建。"
            break
        else
            echo "目录 $NEW_BLOG_DIR 已存在，请输入另一个名称。"
        fi
    done

    BLOG_DIR="$NEW_BLOG_DIR"
fi

cd "$BLOG_DIR"
echo "已进入目录 $BLOG_DIR。"



DOCKER_COMPOSE_FILE="docker-compose.yml"

cat > "$DOCKER_COMPOSE_FILE" << EOL
version: "3"

services:
  vanblog:
    image: mereith/van-blog:latest
    restart: always
    environment:
      TZ: "Asia/Shanghai"
      EMAIL: ""
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

echo "服务开始启动..."

# Wait for the service to be accessible
CHECK_URL="http://localhost:1180"
CHECK_STATUS=0
TIMEOUT=60
TIME_PASSED=0

echo "正在检查服务是否可以访问，请稍候..."

while [ $TIME_PASSED -lt $TIMEOUT ]; do
  curl -s -o /dev/null -w "%{http_code}" $CHECK_URL | grep -q "200" && CHECK_STATUS=1 && break
  sleep 1
  TIME_PASSED=$((TIME_PASSED+1))
done

if [ $CHECK_STATUS -eq 1 ]; then
  PUBLIC_IP=$(curl -s ifconfig.me)
  echo "博客已启动！请访问：http://${PUBLIC_IP}:1180"
else
  echo "博客启动超时，请手动检查服务状态。"
fi

