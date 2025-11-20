# 使用包含 Docker 的基础镜像
FROM docker:dind

# 安装必要的工具和 supervisord
RUN apk add --no-cache \
    supervisor \
    bash \
    curl \
    python3 \
    py3-pip \
    docker-cli

# 创建必要的目录
RUN mkdir -p /var/log/supervisor /home/data /home/user_configs

# 复制配置文件
COPY api.yaml /home/api.yaml
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 提供默认环境变量（可在运行时覆盖）
ENV BOT_TOKEN="" \
    BASE_URL="http://localhost:8000/v1" \
    API_KEY="sk-uni-api-key-12345" \
    MODEL="gpt-4o" \
    CUSTOM_MODELS="gpt-4o" \
    NICK="@openConference1bot" \
    REPLY="true" \
    CHAT_MODE="global" \
    SYSTEMPROMPT="参考https://open-conference.vercel.app/这个网页的内容回复用户回答并且鼓励交流" \
    CONFIG_URL=""

# 暴露端口
# 8080: chatgptbot (Telegram Bot)
# 8000: uni-api
EXPOSE 8080 8000

# 直接启动 supervisord（supervisord 会管理 Docker daemon）
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
