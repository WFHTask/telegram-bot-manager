# Telegram Bot Manager

## 任务：为 MVP 产品 TG 群部署辅助机器人

### 1. 任务目标

为我们的 MVP 产品（[https://open-conference.vercel.app/](https://open-conference.vercel.app/)）的 Telegram 群新增一个辅助机器人。该机器人的主要职责是：

- 为群用户答疑解惑
- 鼓励群交流氛围
- 协助发展 MVP 产品的 Telegram 群测试用户

### 2. 任务内容

- 作为群测试用户运营，你需要负责部署一个 Telegram 机器人
- **参考项目**：[ChatGPT-Telegram-Bot README](https://github.com/yym68686/ChatGPT-Telegram-Bot/blob/main/README_CN.md)
- 将部署好的机器人拉入 TG 测试用户群
- 利用该机器人或通过其他运营方式，为群发展新用户，并鼓励用户参与产品需求设计

### 3. 交付成果

1. 一个已部署并正在运行的 TG 群机器人
2. 一份机器人的**部署和运行过程的录屏**
3. 成功邀请到**新入群的测试用户**（需展示成果）
4. 将所有相关代码（如配置文件）及部署视频链接，推送到指定的 GitHub 代码仓库

### 4. 截止时间

**11 月 5 日 中午 12 点**

---

## Docker 本地部署指南

### 环境要求

1. 已安装并运行 Docker Desktop（Windows/Mac）或 Docker Engine（Linux）
2. 本仓库代码已克隆到本地
3. `user_configs/global.json` 已按需填写机器人配置

### 方式一：直接运行官方镜像

```powershell
docker run -p 8080:8080 --name chatbot -dit `
    -e BOT_TOKEN="<你的 Telegram Bot Token>" `
    -e API_KEY="<你的 OpenAI API Key>" `
    -e BASE_URL="<可选，自建代理地址>" `
    -e MODEL="gpt-4o" `
    -e CUSTOM_MODELS="-all,gpt-4o" `
    -e NICK="@openConference1bot" `
    -e REPLY="true" `
    -e CHAT_MODE="global" `
    -e SYSTEMPROMPT="参考https://open-conference.vercel.app/这个网页的内容回复用户回答并且鼓励交流" `
    -v ${PWD}/user_configs:/home/user_configs `
    yym68686/chatgpt:latest
```

```bash
docker run -p 8080:8080 --name chatbot -dit \
    -e BOT_TOKEN="<你的 Telegram Bot Token>" \
    -e API_KEY="<你的 OpenAI API Key>" \
    -e BASE_URL="<可选，自建代理地址>" \
    -e MODEL="gpt-4o" \
    -e CUSTOM_MODELS="-all,gpt-4o" \
    -e NICK="@openConference1bot" \
    -e REPLY="true" \
    -e CHAT_MODE="global" \
    -e SYSTEMPROMPT="参考https://open-conference.vercel.app/这个网页的内容回复用户回答并且鼓励交流" \
    -v $(pwd)/user_configs:/home/user_configs \
    yym68686/chatgpt:latest
```

> **提示**：PowerShell 中多行命令请使用反引号 `` ` ``，并确保下一行没有额外缩进；在 macOS/Linux 终端请改用 `\` 并使用 `$(pwd)`。

### 方式二：使用本仓库 Dockerfile 构建自定义镜像

**步骤 1：在项目根目录构建镜像**

```bash
docker build -t chatgptbot-custom .
```

**步骤 2（Windows / PowerShell）：运行容器**

```powershell
docker run -p 8080:8080 --name chatbot -dit `
    -e BOT_TOKEN="<你的 Telegram Bot Token>" `
    -v ${PWD}/user_configs:/home/user_configs `
    chatgptbot-custom
```

**步骤 2（Linux / macOS）：运行容器**

```bash
docker run -p 8080:8080 --name chatbot -dit \
    -e BOT_TOKEN="<你的 Telegram Bot Token>" \
    -v $(pwd)/user_configs:/home/user_configs \
    chatgptbot-custom
```

如需长期运行，建议使用 `docker compose`：

```yaml
version: "3.5"
services:
  chatgptbot:
    container_name: chatgptbot
    image: chatgptbot-custom
    # 若不想本地构建，可将上一行改为：image: yym68686/chatgpt:latest
    environment:
      BOT_TOKEN: ""
      BASE_URL: ""
      API_KEY: ""
      MODEL: "gpt-4o"
      CUSTOM_MODELS: "-all,gpt-4o"
      NICK: "@openConference1bot"
      REPLY: "true"
      CHAT_MODE: "global"
      SYSTEMPROMPT: "参考https://open-conference.vercel.app/这个网页的内容回复用户回答并且鼓励交流"
    volumes:
      - ./user_configs:/home/user_configs
    ports:
      - 8080:8080
```

启动命令：

```bash
docker compose up -d --build
```

### 环境变量说明

| 变量 | 说明 |
| --- | --- |
| `BOT_TOKEN` | Telegram BotFather 生成的 Token（必填） |
| `API_KEY` | OpenAI 或自建兼容服务的 API key |
| `BASE_URL` | 可选，若使用代理/自建网关需填写 |
| `MODEL` `CUSTOM_MODELS` | 控制默认模型与可选列表 |
| `NICK` | 机器人呼叫昵称 |
| `REPLY` | 是否自动回复，`true/false` |
| `CHAT_MODE` | `global`/`private` 等模式 |
| `SYSTEMPROMPT` | 自定义系统提示词 |

### 配置文件

- `user_configs/global.json` 与官方项目格式保持一致，可按需复制示例
- 运行容器时务必挂载到 `/home/user_configs`，以便持久化会话与参数
