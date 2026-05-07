# liepin-candidate-search

猎聘候选人搜索与批量打招呼 Skill，让 Claude Code 自动连接你的猎聘账号，批量搜索候选人并发送打招呼消息。

## 功能

- **智能搜索**：根据职位名称、城市、工作年限、学历等条件筛选候选人
- **批量打招呼**：自动循环联系候选人，达到指定数量后停止
- **状态追踪**：自动识别已联系/未联系的候选人（"继续沟通" vs "立即沟通"）
- **汇总报告**：完成后输出已联系候选人的详细信息表格

## 安装

### 一键安装（推荐）

```bash
npx skills add colin66611/liepin-candidate-search
```

这会将 skill 安装到 `~/.claude/skills/liepin-candidate-search/`（macOS/Linux）或 `%USERPROFILE%\.claude\skills\liepin-candidate-search\`（Windows），Claude Code 会自动识别。

### 手动安装

```bash
git clone https://github.com/colin66611/liepin-candidate-search.git
cp -r liepin-candidate-search ~/.claude/skills/
```

## 环境要求

| 依赖 | 说明 |
|------|------|
| **Node.js** (>=18) | 运行 agent-browser |
| **agent-browser** | 浏览器自动化 CLI，`npm install -g agent-browser` |
| **Google Chrome / Microsoft Edge** | 需要以 CDP 模式启动（Windows 推荐 Edge） |
| **猎聘账号** | 需要在 h.liepin.com 登录 |

### 启动浏览器（CDP 模式）

```bash
# macOS
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222 &

# Linux
google-chrome --remote-debugging-port=9222 &

# Windows - Edge（推荐，无安全限制）
"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --remote-debugging-port=9222

# Windows - Chrome（需指定 user-data-dir）
"C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222 --user-data-dir="C:\temp\chrome-debug"
```

> **Windows 重要说明**：
> 1. 启动前先完全退出浏览器（任务管理器确认无 chrome.exe/msedge.exe 进程），否则 CDP 端口可能无法绑定
> 2. **Chrome M144+ 安全限制**：Windows 上 Chrome 要求 `--remote-debugging-port` 必须配合 `--user-data-dir` 使用，不能直接用默认 profile。推荐使用 **Edge** 浏览器，没有此限制

启动后在打开的浏览器中登录 https://h.liepin.com

### 安装 agent-browser（Windows 特别说明）

```bash
# macOS / Linux
npm install -g agent-browser

# Windows
npm install -g agent-browser
# 如果 npm 全局安装失败，可手动下载 Windows 二进制文件：
# 1. 访问 https://github.com/vercel-labs/agent-browser/releases
# 2. 下载对应版本的 Windows x64 二进制文件
# 3. 将文件放入 PATH 目录（如 C:\Windows\）
```

> **已知问题**：Windows 上 `npm install -g agent-browser` 可能因 PowerShell wrapper 脚本问题失败（[issue #108](https://github.com/vercel-labs/agent-browser/issues/108)）。如果安装失败，推荐：
> - 使用 **WSL**（Windows Subsystem for Linux），与 macOS/Linux 操作一致
> - 或手动下载二进制文件

### 环境检测

```bash
# macOS / Linux
bash ~/.claude/skills/liepin-candidate-search/setup.sh

# Windows (PowerShell)
powershell -ExecutionPolicy Bypass -File %USERPROFILE%\.claude\skills\liepin-candidate-search\setup.ps1
```

一键检查 Node.js、agent-browser、Chrome CDP 是否就绪。

## 使用方法

在 Claude Code 中直接说出需求即可，agent 会自动加载此 skill：

> "帮我和 10 位嵌入式软件经理的猎聘候选人打招呼"

Agent 会依次询问：
1. **目标职位**（必须是你已在猎聘发布的职位）
2. **筛选条件**（城市、年限、学历、活跃度等）
3. **打招呼数量**
4. **招呼语选择**（可选，默认第一条）

确认后自动执行搜索和批量联系。

## 工作流程

```
收集需求 → 连接浏览器 → 设置筛选条件 → 批量打招呼 → 汇总报告
```

### 批量打招呼流程

对每位候选人：
1. 滚动页面使"立即沟通"按钮可见
2. 点击"立即沟通"打开弹窗
3. 通过 JS 操作 Ant Design Select 选择职位
4. 点击"立即开聊"发送消息
5. 验证按钮变为"继续沟通"确认成功

## 技术原理

- **Chrome DevTools Protocol (CDP)**：连接真实浏览器，使用你的登录态
- **agent-browser CLI**：语义化定位元素（find text/label/click）
- **Ant Design Modal 操作**：弹窗内容不在可访问性树中，通过 JS 直接操作 DOM
- **成功验证**：按钮文字从"立即沟通"变为"继续沟通"

## 注意事项

- 每次操作间隔 2-3 秒，模拟人工速度，避免被反爬
- 操作过程中猎聘会弹出推广弹窗，agent 会自动关闭
- 已联系过的候选人会自动跳过
- 建议使用 Chrome 无痕模式登录猎聘，避免 Cookie 冲突
- **Windows 用户**：启动 CDP 模式前请确保 Chrome 完全退出，否则端口 9222 可能无法绑定

## 目录结构

```
liepin-candidate-search/
├── SKILL.md          # Skill 主文件（Claude Code 读取）
├── README.md         # 安装和使用说明
├── setup.sh          # 环境检测脚本（macOS/Linux）
├── setup.ps1         # 环境检测脚本（Windows PowerShell）
└── .gitignore
```

## 许可证

MIT
