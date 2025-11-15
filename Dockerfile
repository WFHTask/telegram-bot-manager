FROM yym68686/chatgpt:latest

# 提供与 docker-compose.yml 中一致的默认环境变量（可在运行时覆盖）
ENV BOT_TOKEN="" \
    BASE_URL="" \
    API_KEY="" \
    MODEL="gpt-4o" \
    CUSTOM_MODELS="-all,gpt-4o" \
    NICK="@openConference1bot" \
    REPLY="true" \
    CHAT_MODE="global" \
    SYSTEMPROMPT="参考https://open-conference.vercel.app/这个网页的内容回复用户回答并且鼓励交流"

# 预创建配置目录（运行容器时仍可通过 -v 进行挂载）
RUN mkdir -p /home/user_configs
VOLUME ["/home/user_configs"]

# 镜像本身已包含启动命令，这里只需公开服务端口
EXPOSE 8080

