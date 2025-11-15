## Docker 本地部署


启动容器

```bash
docker run -p 8080:8080 --name chatbot -dit \
    -e BOT_TOKEN=your_telegram_bot_token \
    -e API_KEY= \
    -e BASE_URL= \
    -v ./user_configs:/home/user_configs \
    yym68686/chatgpt:latest
```

或者如果你想使用 Docker Compose，这里有一个 docker-compose.yml 示例：

```yaml
version: "3.5"
services:
  chatgptbot:
    container_name: chatgptbot
    image: yym68686/chatgpt:latest
    environment:
      - BOT_TOKEN=
      - API_KEY=
      - BASE_URL=
    volumes:
      - ./user_configs:/home/user_configs
    ports:
      - 8080:8080
```

在后台运行 Docker Compose 容器

```bash
docker compose pull
docker compose up -d
```
