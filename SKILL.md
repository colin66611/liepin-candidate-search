---
name: liepin-candidate-search
description: |
  How to search for candidates on Liepin (猎聘) and contact them at scale.
  Use when the user mentions 猎聘, liepin, headhunting, candidate sourcing,
  resume search, 人才搜索, 打招呼, contacting candidates on recruitment platforms,
  or wants to automate finding and messaging candidates on h.liepin.com.
  Works with any Chrome browser that has an active Liepin login session — connects via CDP
  (Chrome DevTools Protocol) using agent-browser so the agent uses your real logged-in browser.
  Make sure to use this skill whenever the user wants to search candidates, batch-contact
  candidates, or automate any workflow on the Liepin recruitment platform.
---

# 猎聘候选人搜索与打招呼

通过 agent-browser 连接已登录猎聘的真实 Chrome 浏览器，
自动搜索候选人并批量发送打招呼消息。

## 前置条件

用户需要确保：
1. 已安装 agent-browser：`npm install -g agent-browser` 或 `brew install agent-browser`
   - **Windows 注意**：如果 npm 全局安装失败，可手动下载 Windows 二进制文件：
     https://github.com/vercel-labs/agent-browser/releases
2. Chrome（macOS/Linux）或 Edge（Windows）浏览器已启动，且已登录猎聘账号（`h.liepin.com`）
3. 浏览器以远程调试模式启动：
   ```bash
   # macOS
   /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222 &

   # Linux
   google-chrome --remote-debugging-port=9222 &

   # Windows（Edge，推荐）
   "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --remote-debugging-port=9222
   ```
   > **Windows 注意**：启动前请先完全退出 Edge（任务管理器确认无 msedge.exe 进程），否则 CDP 端口可能无法绑定。

## 核心定位策略

猎聘页面是动态 SPA，元素 ref 每次 snapshot 都会变化。**永远不要写死 ref 编号**（如 @e123）。

使用 **语义定位器**（semantic locators）通过文本内容定位元素：

```bash
# 按按钮文本点击
agent-browser --cdp 9222 find text "搜索" click
agent-browser --cdp 9222 find text "立即沟通" click
agent-browser --cdp 9222 find text "立即开聊" click

# 按 LabelText 点击筛选项
agent-browser --cdp 9222 find label "5-10年" click
agent-browser --cdp 9222 find label "本科" click
agent-browser --cdp 9222 find label "上海" click

# 按 placeholder 找到下拉框
agent-browser --cdp 9222 find placeholder "请选择开聊的职位" click
```

**每次页面变化后必须重新 snapshot 或截图**，因为 ref 会失效。

## 工作流程

### 第一阶段：收集需求

依次询问用户以下信息，**每问完一项确认后再继续下一项**：

**1. 目标职位**
- 询问猎头要搜索哪个职位的候选人
- 这个职位必须是猎头在猎聘上已发布的职位（页面会显示"正在发布的职位"列表）

**2. 筛选条件**
列出猎聘搜索页面的所有可选筛选条件，让用户逐一选择：

| 筛选项 | 可选值 |
|--------|--------|
| 关键词匹配 | 包含全部关键词、包含任意关键词、不包含以下关键词 |
| 职位名称 | 用户输入 |
| 公司名称 | 用户输入 |
| 目前城市 | 不限、上海、北京、广州、深圳、杭州、天津、成都、南京、其他 |
| 期望城市 | 不限、上海、北京、广州、深圳、杭州、天津、成都、南京、其他 |
| 工作年限 | 不限、应届生、1-3年、3-5年、5-10年、10年以上、自定义 |
| 教育经历 | 不限、本科、硕士、博士/博士后、大专、中专/中技、高中及以下 |
| 统招要求 | 统招/非统招（不限）、统招、非统招 |
| 院校要求 | 不限、211、985、双一流、海外留学 |
| 当前行业 | 自由输入 |
| 当前职位 | 自由输入 |
| 年龄范围 | 岁 — 岁 |
| 活跃度 | 不限、今天活跃、3天内活跃、7天内活跃、30天内活跃 |
| 性别 | 不限、男、女 |
| 跳槽频率 | 不限、≤1次/2年、≤1次/年、≥2次/年 |

**3. 打招呼数量**
- 询问用户本次要联系多少个候选人

**4. 招呼语选择（可选）**
- 弹窗中有 5 种默认招呼语，默认使用第一条
- 如果用户想选其他，记录序号

### 第二阶段：连接浏览器并导航

```bash
# 连接 Chrome CDP
agent-browser connect 9222

# 导航到搜索页面
agent-browser --cdp 9222 goto https://h.liepin.com/search/getConditionItem
agent-browser --cdp 9222 wait --load networkidle

# 截图确认
agent-browser --cdp 9222 screenshot /tmp/liepin-search.png
```

### 第三阶段：设置搜索条件

**Step 1：选择已发布的职位**

猎聘的搜索是基于已发布职位的。页面会显示"正在发布的职位"列表。

```bash
# 获取快照，找到职位列表项
agent-browser --cdp 9222 snapshot -i

# 找到包含用户指定职位的 listitem 并点击
# 例如找到 "嵌入式软件经理（上海蔚来汽车有限公司 | 上海 | 40k-45k）"
# 使用 find text 定位职位文本（部分匹配即可）
agent-browser --cdp 9222 find text "嵌入式软件经理" click
```

**注意**：如果页面有多个包含该职位文本的元素，先 snapshot 确认 ref，然后用 `click @eN` 精确点击职位列表项。

**Step 2：设置筛选条件**

对每个用户选择的筛选项，使用 `find label` 点击对应的 LabelText 元素：

```bash
# 目前城市 = 上海
agent-browser --cdp 9222 find label "上海" click
agent-browser --cdp 9222 wait 500

# 工作年限 = 5-10年
agent-browser --cdp 9222 find label "5-10年" click
agent-browser --cdp 9222 wait 500

# 教育经历 = 本科
agent-browser --cdp 9222 find label "本科" click
agent-browser --cdp 9222 wait 500

# 院校要求 = 985
agent-browser --cdp 9222 find label "985" click
agent-browser --cdp 9222 wait 500
```

**注意**：每个筛选项的 LabelText 在页面上是直接可见的，不需要先展开某个下拉框。直接用 `find label "文本"` 即可定位。

**Step 3：点击搜索**

```bash
agent-browser --cdp 9222 find text "搜索" click
agent-browser --cdp 9222 wait --load networkidle

# 截图确认搜索结果
agent-browser --cdp 9222 screenshot /tmp/liepin-results.png
```

### 第四阶段：批量打招呼

循环执行，直到达到目标人数。

**重要**：猎聘的"请选择职位开聊"弹窗是 Ant Design Modal，弹窗内的 Ant Select 组件**不在可访问性树中**。必须用 JS 操作下拉框选择职位。

**Step 1：获取当前页面快照**

```bash
agent-browser --cdp 9222 snapshot -i
```

**Step 2：找到第一个"立即沟通"按钮并滚动到可见位置**

```bash
# 滚动页面使候选人列表按钮可见
agent-browser --cdp 9222 eval "window.scrollTo(0, 750)"
agent-browser --cdp 9222 wait 500

# 从 snapshot 中找到第一个 button "立即沟通" 的 ref
agent-browser --cdp 9222 snapshot -i
```

**注意**：未联系过 = "立即沟通"，已联系过 = "继续沟通"。只点"立即沟通"。

**Step 3：点击"立即沟通"**

```bash
agent-browser --cdp 9222 click @eN  # 用 snapshot 中找到的 ref
agent-browser --cdp 9222 wait 1500
```

**Step 4：在弹窗中选择职位**

⚠️ **重要警告**：弹窗打开后 snapshot 会包含整个页面（弹窗 + 背景搜索页）。
**绝对不能**用 ref 点击职位选择，因为 ref 可能指向左侧职位列表的卡片（如 `@e45`），不是弹窗内的选项。

**正确方法**：必须用 JS 操作 Ant Design Select 的 DOM 元素。

```bash
# ❌ 错误做法（会导致选择失败）：
# agent-browser --cdp 9222 click @e45  # 这是左侧职位列表，不是弹窗选项！

# ✅ 正确方法A：点击 Select 展开下拉，然后点击选项（推荐）
agent-browser --cdp 9222 eval "(function(){
  const modal = document.querySelector('.ant-modal');
  if(!modal) return 'no modal';
  const select = modal.querySelector('.ant-select-in-form-item');
  if(!select) return 'no select';
  // 点击展开
  select.dispatchEvent(new MouseEvent('mousedown', {bubbles:true,view:window}));
  select.dispatchEvent(new MouseEvent('click', {bubbles:true,view:window}));
  return 'clicked select';
})()"
agent-browser --cdp 9222 wait 1000

# 点击下拉框中的职位选项
agent-browser --cdp 9222 eval "(function(){
  const dropdown = document.querySelectorAll('.ant-select-dropdown')[1];
  if(!dropdown) return 'no dropdown';
  const option = dropdown.querySelector('.ant-select-item-option');
  if(!option) return 'no option';
  option.click();
  return 'clicked: ' + option.textContent.trim().substring(0, 40);
})()"
```

**Step 5：点击"立即开聊"**

```bash
# 立即开聊按钮在 snapshot 中可见
agent-browser --cdp 9222 snapshot -i
# 找到 button "立即开聊" 的 ref
agent-browser --cdp 9222 click @eN
```

**Step 6：等待弹窗关闭并验证**

```bash
agent-browser --cdp 9222 wait 3000
```

**验证打招呼成功**：重新 snapshot，检查该候选人的按钮文字从"立即沟通"变为"继续沟通"。

```bash
agent-browser --cdp 9222 snapshot -i
# 查看该候选人 cell 中的按钮文字
# "立即沟通" -> "继续沟通" = 成功
```

**Step 7：记录已联系候选人信息**

从 snapshot 中该候选人 cell 的文本中提取：
- 姓名、年龄、工作年限、学历、城市、当前公司、当前职位

**Step 8：检查数量**

如果未达到目标人数，继续循环。当前页面候选人全部联系完后执行翻页：

```bash
agent-browser --cdp 9222 snapshot -i
agent-browser --cdp 9222 find text "下一页" click
agent-browser --cdp 9222 wait --load networkidle
agent-browser --cdp 9222 wait 2000
agent-browser --cdp 9222 eval "window.scrollTo(0, 750)"
agent-browser --cdp 9222 wait 500
```

### 第五阶段：汇总报告

任务完成后输出：

```
## 猎聘候选人联系报告

**搜索职位：** [职位名称]
**筛选条件：** [列出用户选择的所有筛选条件]
**联系人数：** X 人

### 已联系候选人

| 序号 | 姓名 | 年龄 | 工作年限 | 当前公司 | 当前职位 | 城市 |
|------|------|------|----------|----------|----------|------|
| 1 | 王** | 33岁 | 8年 | 新华三技术有限公司 | 嵌入式软件开发经理 | 上海 |
| 2 | 曾** | 26岁 | 5年 | 易兆微电子 | 嵌入式软件工程师 | 上海 |
| ... | ... | ... | ... | ... | ... | ... |

**执行完成时间：** YYYY-MM-DD HH:MM
```

## 关键技术要点

### agent-browser 核心命令速查

| 操作 | 命令 |
|------|------|
| 连接 CDP | `agent-browser connect 9222` 或 `agent-browser connect http://localhost:9222` |
| 导航 | `agent-browser --cdp 9222 goto <url>` |
| 快照 | `agent-browser --cdp 9222 snapshot -i` |
| 按文本点击 | `agent-browser --cdp 9222 find text "文本" click` |
| 按第一个匹配点击 | `agent-browser --cdp 9222 find first text "文本" click` |
| 按label点击 | `agent-browser --cdp 9222 find label "文本" click` |
| 按placeholder点击 | `agent-browser --cdp 9222 find placeholder "文本" click` |
| 按ref点击 | `agent-browser --cdp 9222 click @eN` |
| 填充表单 | `agent-browser --cdp 9222 fill @eN "内容"` |
| 获取文本 | `agent-browser --cdp 9222 get text @eN` |
| 等待加载 | `agent-browser --cdp 9222 wait --load networkidle` |
| 等待时间 | `agent-browser --cdp 9222 wait 2000` |
| 截图 | `agent-browser --cdp 9222 screenshot <path>` |
| 带标注截图 | `agent-browser --cdp 9222 screenshot --annotate <path>` |
| 页面滚动 | `agent-browser --cdp 9222 eval "window.scrollTo(0, Y)"` |

### 操作间隔

每次操作之间等待 2-3 秒，模拟人工速度：

```bash
agent-browser --cdp 9222 wait 2000
```

### 弹窗处理

猎聘的"请选择职位开聊"弹窗是 Ant Design Modal 组件。

⚠️ **关键陷阱**：弹窗打开后 snapshot 会包含整个页面（弹窗 + 背景搜索页）。
- snapshot 中的职位 ref（如 `@e45`）可能是左侧职位列表的卡片，**不是弹窗内的职位选项**
- **必须用 JS 操作弹窗内的下拉框**，不能用 ref 点击职位选择

**弹窗定位策略**：

| 步骤 | 方法 | 说明 |
|------|------|------|
| 打开弹窗 | `click @eN`（"立即沟通"按钮ref） | agent-browser 原生点击 |
| 展开下拉 | JS dispatch mousedown+click on `.ant-select-in-form-item` | **不能用 ref，必须用 JS** |
| 选择职位 | JS click on `.ant-select-item-option` | 在 `.ant-select-dropdown` 中找到选项 |
| 发送消息 | `click @eN`（"立即开聊"按钮ref） | 该按钮在 snapshot 中可见 |
| 验证成功 | snapshot 检查按钮变为"继续沟通" | 按钮文字变化 = 打招呼成功 |

**关键 JS 操作**：

```bash
# 展开下拉框
agent-browser --cdp 9222 eval "(function(){
  const modal = document.querySelector('.ant-modal');
  const select = modal.querySelector('.ant-select-in-form-item');
  select.dispatchEvent(new MouseEvent('mousedown', {bubbles:true,view:window}));
  select.dispatchEvent(new MouseEvent('click', {bubbles:true,view:window}));
  return 'expanded';
})()"

# 选择职位选项（取第一个匹配用户职位的选项）
agent-browser --cdp 9222 eval "(function(){
  const dropdown = document.querySelectorAll('.ant-select-dropdown')[1];
  const option = dropdown.querySelector('.ant-select-item-option');
  option.click();
  return 'selected: ' + option.textContent.trim();
})()"
```

### 已联系 vs 未联系

| 按钮文本 | 含义 |
|---------|------|
| "立即沟通" | 未联系过，可以点击 |
| "继续沟通" | 已联系过，跳过 |

## 错误处理

- **CDP 连接失败**：提示用户检查 Chrome 是否以 `--remote-debugging-port=9222` 启动
  - Windows 用户：请确保启动前 Chrome 已完全退出（任务管理器确认无 chrome.exe 进程）
- **"立即沟通"按钮点击无反应**：按钮可能在视口外，先执行 `eval "window.scrollTo(0, 750)"` 滚动
- **弹窗打开后后续操作失败**：可能是用 `eval` JS click 打开的弹窗，React 事件未正确触发。关闭弹窗后改用 `click @eN`
- **职位下拉框无法展开**：弹窗内的 Ant Select **不能用 ref 点击**（ref 可能指向左侧职位列表），必须用 JS 操作 `.ant-select-in-form-item`
- **选择职位后"立即开聊"仍提示选择职位**：
  - ⚠️ **最常见错误**：点击了 snapshot 中的职位 ref（如 `@e45`），但这是左侧职位列表卡片，不是弹窗内的职位选项
  - **解决方法**：必须用 JS eval 操作 DOM（见 Step 4 的正确方法）
  - 确认 JS 点击的是 `.ant-select-item-option` 元素（在 `.ant-select-dropdown` 中）
- **验证打招呼是否成功**：检查候选人 cell 中按钮文字从"立即沟通"变为"继续沟通"
- **操作被反爬拦截**：降低操作频率，增加等待时间到 3-5 秒
- **筛选项 LabelText 找不到**：运行 `snapshot -i` 查看实际页面结构，确认文本是否完全匹配

## 关闭浏览器

任务完成后：
```bash
agent-browser --cdp 9222 close
```
