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

这会将 skill 安装到 `~/.claude/skills/liepin-candidate-search/`，Claude Code 会自动识别。

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
| **Google Chrome** | 需要以 CDP 模式启动 |
| **猎聘账号** | 需要在 h.liepin.com 登录 |

### 启动 Chrome（CDP 模式）

```bash
# macOS
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222 &

# Linux
google-chrome --remote-debugging-port=9222 &
```

启动后在打开的 Chrome 中登录 https://h.liepin.com

### 环境检测

```bash
bash ~/.claude/skills/liepin-candidate-search/setup.sh
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

## 目录结构

```
liepin-candidate-search/
├── SKILL.md          # Skill 主文件（Claude Code 读取）
├── README.md         # 安装和使用说明
├── setup.sh          # 环境检测脚本
└── .gitignore
```

## 许可证

MIT
