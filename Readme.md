# Telegram Bot Manager

基于 uni-api 和 ChatGPT-Telegram-Bot 的 Telegram 机器人部署方案。

## 项目架构

```
┌─────────────────┐
│  Telegram Bot   │ (chatgptbot)
│   Port: 8080    │
└────────┬────────┘
         │
         │ BASE_URL
         ▼
┌─────────────────┐
│    uni-api      │ (统一 AI 网关)
│   Port: 8000    │
└─────────────────┘
         │
         ├─ Gemini API
         ├─ OpenAI API
         └─ 其他 AI 提供商
```

## 快速启动

### 方式一：Docker Compose（本地开发推荐）

**前提条件：**
- 已安装 Docker Desktop（Windows/Mac）或 Docker Engine（Linux）
- 已配置 `api.yaml` 文件（包含 API Keys）

**启动步骤：**

```bash
# 1. 进入项目目录
cd telegram-bot-manager

# 2. 启动服务（后台运行）
docker compose up -d

# 3. 查看服务状态
docker compose ps

# 4. 查看日志
docker compose logs -f

# 5. 停止服务
docker compose down
```

**验证服务：**

```bash
# 测试 uni-api
curl http://localhost:8000/v1/models

# 查看服务日志
docker compose logs -f chatgptbot
docker compose logs -f uni-api
```

**服务说明：**
- **uni-api**: 运行在 `http://localhost:8000`（对外暴露）
- **chatgptbot**: 运行在 `http://localhost:8080`（对外暴露）
- **内部通信**: chatgptbot 通过 `http://uni-api:8000/v1` 访问 uni-api（使用 Docker Compose 服务名）

---

### 方式二：Railway 部署（生产环境）

Railway 不支持 docker-compose，需要将两个服务分别部署为独立的 Service。

#### 部署架构

```
Railway Project
├─ Service 1: uni-api-service (端口 8000)
│  └─ 公共 URL: https://uni-api-xxxxx.up.railway.app
└─ Service 2: chatgptbot-service (端口 8080)
   └─ 通过 uni-api 的公共 URL 访问
```

#### 步骤 1：部署 uni-api 服务

1. **在 Railway 创建新项目**
   - 登录 Railway，点击 "New Project"
   - 项目名称：例如 `open-conference-bot`

2. **添加 uni-api 服务**
   - 点击 "New Service" → "Deploy from GitHub Repo"
   - 选择你的 GitHub 仓库
   - Railway 会自动检测 `Dockerfile.uni-api`
   - 或手动指定：Settings → Build → Dockerfile Path = `Dockerfile.uni-api`

   > **注意**：如果仓库中有 `railway.json` 文件，它会被自动使用。在双服务模式下，建议在 Railway 界面中手动指定 Dockerfile 路径，或在每个服务的设置中覆盖 `railway.json` 的配置。

3. **配置端口**
   - Settings → Networking → Port = `8000`

4. **获取公共 URL**
   - Settings → Networking → Public Domain
   - 复制域名，例如：`https://uni-api-xxxxx.up.railway.app`
   - **重要**：这个 URL 稍后需要在 chatgptbot 的 `BASE_URL` 中使用

5. **配置 Volume（可选，用于数据持久化）**
   - 如果需要统计数据功能，可以创建 Volume：
     - Settings → Volumes
     - 创建 Volume，挂载路径：`/home/data`
     - 用于保存 uni-api 的统计数据
   - **注意**：默认不启用统计数据，可以跳过此步骤

6. **环境变量（可选）**
   - 如果使用远程配置文件，添加：
     - `CONFIG_URL`: 远程配置文件 URL（例如 GitHub Gist 直链）

#### 步骤 2：部署 chatgptbot 服务

1. **在同一项目中添加新服务**
   - 在同一个 Railway Project 中，点击 "New Service" → "Deploy from GitHub Repo"
   - 选择同一个 GitHub 仓库
   - Railway 会自动检测 `Dockerfile.chatgptbot`
   - 或手动指定：Settings → Build → Dockerfile Path = `Dockerfile.chatgptbot`

2. **配置端口**
   - Settings → Networking → Port = `8080`

3. **配置环境变量（重要）**
   - Settings → Variables
   - 添加以下环境变量（详见下方"环境变量说明"）：
     - `BOT_TOKEN` ⚠️ **必须使用 Railway Secret**
     - `BASE_URL` = `https://uni-api-xxxxx.up.railway.app/v1`（使用步骤 1 中获取的 URL）
     - `API_KEY` ⚠️ **必须使用 Railway Secret**（需与 `api.yaml` 中的 `api_keys` 一致）
     - `MODEL`、`CUSTOM_MODELS`、`NICK`、`REPLY`、`CHAT_MODE`、`SYSTEMPROMPT` 等

4. **配置 Volume（可选，用于配置持久化）**
   - Settings → Volumes
   - 创建 Volume，挂载路径：`/home/user_configs`
   - 用于保存 Telegram Bot 的用户配置

#### 验证部署

1. **检查 uni-api 服务**
   ```bash
   # 访问 uni-api 的公共域名
   curl https://your-uni-api.railway.app/v1/models
   # 应该返回模型列表 JSON
   ```

2. **检查 chatgptbot 服务**
   - 查看 Railway 服务日志，确认能连接到 uni-api
   - 在 Telegram 中测试机器人是否响应

---

## 环境变量说明

### uni-api 服务环境变量

| 变量名 | 说明 | 是否必需 | 默认值 | 示例 |
|--------|------|---------|--------|------|
| `CONFIG_URL` | 远程配置文件 URL | 否 | - | `https://gist.githubusercontent.com/xxx/api.yaml` |

**说明：**
- 如果使用 `Dockerfile.uni-api`，配置文件会在构建时 `COPY` 到镜像中，无需此环境变量
- 如果使用远程配置文件，设置此变量后，uni-api 会自动下载并加载配置
- 配置文件格式见 `api.yaml` 示例

### chatgptbot 服务环境变量

#### 必需环境变量

| 变量名 | 说明 | 是否必需 | 示例 |
|--------|------|---------|------|
| `BOT_TOKEN` | Telegram Bot Token | ✅ 必需 | `` |
| `BASE_URL` | uni-api 服务地址 | ✅ 必需 | `http://uni-api:8000/v1`（本地）<br>`https://uni-api-xxxxx.up.railway.app/v1`（Railway） |
| `API_KEY` | uni-api 的 API Key | ✅ 必需 | `sk-uni-api-key-12345` |

**重要说明：**
- `BOT_TOKEN`: 从 [@BotFather](https://t.me/BotFather) 获取，⚠️ **必须使用 Railway Secret**
- `BASE_URL`: 
  - Docker Compose: 使用服务名 `http://uni-api:8000/v1`
  - Railway: 使用 uni-api 的公共 URL `https://uni-api-xxxxx.up.railway.app/v1`
  - **必须包含 `/v1` 前缀**（uni-api 使用 OpenAI 格式 API）
- `API_KEY`: 必须与 `api.yaml` 中 `api_keys` 配置的 Key 一致，⚠️ **必须使用 Railway Secret**

#### 可选环境变量

| 变量名 | 说明 | 默认值 | 示例 |
|--------|------|--------|------|
| `MODEL` | 默认使用的 AI 模型 | `gpt-4o` | `gpt-4o`<br>`gemini-2.5-flash`<br>`gpt-4o-mini` |
| `CUSTOM_MODELS` | 允许用户选择的模型列表 | `-all` | `-all,gemini-2.5-flash,gpt-4o,gpt-4o-mini` |
| `NICK` | Bot 的昵称（用于触发回复） | `@openConference1bot` | `@your_bot_name` |
| `REPLY` | 是否在群组中回复消息 | `true` | `true` / `false` |
| `CHAT_MODE` | 聊天模式 | `global` | `global`（全局）<br>`user`（用户独立） |
| `SYSTEMPROMPT` | 系统提示词 | - | `参考https://open-conference.vercel.app/这个网页的内容回复用户回答并且鼓励交流` |
| `CONFIG_URL` | 远程配置文件 URL | - | `https://example.com/config.json` |

**详细说明：**

- **`MODEL`**: 
  - 指定默认使用的 AI 模型
  - 必须是 `api.yaml` 中配置的模型之一
  - 常见值：`gpt-4o`、`gpt-4o-mini`、`gemini-2.5-flash`、`gemini-1.5-pro` 等

- **`CUSTOM_MODELS`**:
  - 控制用户在 Telegram 中可以选择哪些模型
  - `-all` 表示允许使用所有配置的模型
  - 格式：`-all,model1,model2,model3` 或 `model1,model2,model3`
  - 示例：`-all,gemini-2.5-flash,gpt-4o,gpt-4o-mini`

- **`NICK`**:
  - Bot 的 Telegram 用户名（带 @ 符号）
  - 在群组中，如果消息中包含此昵称，Bot 会回复
  - 示例：`@openConference1bot`

- **`REPLY`**:
  - 在群组中是否自动回复消息
  - `true`: 自动回复（如果消息包含 `NICK` 或直接 @Bot）
  - `false`: 只在私聊中回复

- **`CHAT_MODE`**:
  - `global`: 所有用户共享同一个对话上下文
  - `user`: 每个用户有独立的对话上下文

- **`SYSTEMPROMPT`**:
  - 系统提示词，用于设置 Bot 的行为和角色
  - 会作为第一条系统消息发送给 AI 模型
  - 示例：`参考https://open-conference.vercel.app/这个网页的内容回复用户回答并且鼓励交流`

---

## 配置文件说明

### api.yaml（uni-api 配置文件）

`api.yaml` 用于配置 uni-api 的 AI 模型提供商和 API Keys。

**文件位置：**
- Docker Compose: `./api.yaml`（挂载到容器）
- Railway: 构建时 `COPY` 到镜像，或通过 `CONFIG_URL` 远程加载

**配置示例：**

```yaml
providers:
  - provider: gemini
    base_url: https://generativelanguage.googleapis.com/v1beta
    api: YOUR_GEMINI_API_KEY  # 替换为你的 Gemini API Key
    model:
      - gemini-2.5-flash
      - gemini-1.5-pro
      - gemini-1.5-flash

  - provider: openai
    base_url: https://api.openai.com/v1
    api: YOUR_OPENAI_API_KEY  # 替换为你的 OpenAI API Key
    model:
      - gpt-4o
      - gpt-4o-mini
      - gpt-4-turbo

api_keys:
  - api: sk-uni-api-key-12345  # uni-api 的 API Key，chatgptbot 使用此 Key 访问
```

**重要说明：**
- `providers`: 配置 AI 模型提供商（Gemini、OpenAI 等）
- `api_keys`: uni-api 的访问密钥，必须与 chatgptbot 的 `API_KEY` 环境变量一致
- ⚠️ **不要将包含真实 API Key 的 `api.yaml` 提交到公开仓库**

---

## 常见问题

### Docker Compose

**Q: 如何查看服务日志？**
```bash
docker compose logs -f chatgptbot
docker compose logs -f uni-api
```

**Q: 服务无法启动怎么办？**
1. 检查 `api.yaml` 格式是否正确
2. 检查环境变量是否配置正确
3. 查看服务日志：`docker compose logs`

**Q: chatgptbot 无法连接到 uni-api？**
- 确认 `BASE_URL` 设置为 `http://uni-api:8000/v1`（包含 `/v1` 前缀）
- 确认两个服务都在运行：`docker compose ps`

### Railway 部署

**Q: 如何获取 uni-api 的公共 URL？**
- 在 Railway 中打开 `uni-api-service`
- Settings → Networking → Public Domain
- 复制显示的 URL

**Q: BASE_URL 应该使用哪个域名？**
- **推荐**：使用公共 URL `https://uni-api-xxxxx.up.railway.app/v1`
- 如果两个服务在同一 Project，也可以使用私有域名 `${{uni-api.RAILWAY_PRIVATE_DOMAIN}}/v1`
- **必须包含 `/v1` 前缀**

**Q: 如何更新配置文件？**
- 如果使用 Dockerfile：修改 `api.yaml` 后重新构建镜像
- 如果使用 `CONFIG_URL`：更新远程文件，重启服务

**Q: 如何重置泄露的 API Key？**
- **BOT_TOKEN**: 在 [@BotFather](https://t.me/BotFather) 中撤销旧 Token，生成新 Token
- **API_KEY**: 修改 `api.yaml` 中的 `api_keys`，重新部署 uni-api 服务
- 在 Railway 中更新环境变量（使用 Railway Secret）

**Q: 服务间通信失败？**
- 确认 `BASE_URL` 包含 `/v1` 前缀
- 确认 uni-api 服务正常运行（访问公共 URL 测试）
- 查看 chatgptbot 日志，检查连接错误信息

---

## 安全提醒

⚠️ **重要安全提示：**

1. **不要将包含真实 API Key 的配置文件提交到公开仓库**
2. **在 Railway 中使用 Secret 存储敏感信息**（BOT_TOKEN、API_KEY）
3. **定期轮换 API Keys**，特别是如果怀疑已泄露
4. **使用环境变量而非硬编码**来管理敏感配置

---

## 参考链接

- [uni-api GitHub](https://github.com/yym68686/uni-api)
- [ChatGPT-Telegram-Bot GitHub](https://github.com/yym68686/ChatGPT-Telegram-Bot)
- [Railway 文档](https://docs.railway.app/)
- [Telegram Bot API](https://core.telegram.org/bots/api)
