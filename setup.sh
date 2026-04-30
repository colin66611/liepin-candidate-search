#!/bin/bash
# 猎聘候选人搜索 Skill - 环境检测脚本
# 运行此脚本检查所有依赖是否已安装

set -e

echo "========================================="
echo "  猎聘候选人搜索 Skill - 环境检测"
echo "========================================="

PASS=0
FAIL=0
WARN=0

check() {
  local name="$1"
  local cmd="$2"
  if eval "$cmd" &>/dev/null; then
    echo "  ✅ $name"
    ((PASS++))
    return 0
  else
    echo "  ❌ $name"
    ((FAIL++))
    return 1
  fi
}

warn() {
  local name="$1"
  local cmd="$2"
  if eval "$cmd" &>/dev/null; then
    echo "  ✅ $name"
    ((PASS++))
    return 0
  else
    echo "  ⚠️  $name (可选，但建议安装)"
    ((WARN++))
    return 1
  fi
}

echo ""
echo "--- 核心依赖 ---"

check "Node.js (>=18)" "command -v node && [ \$(node -e 'console.log(parseInt(process.versions.node.split(\".\")[0]))' ) -ge 18 ]"

check "npm" "command -v npm"

echo ""
echo "--- agent-browser ---"
if check "agent-browser CLI" "command -v agent-browser"; then
  echo "     版本: $(agent-browser --version 2>/dev/null || echo 'unknown')"
fi

echo ""
echo "--- Chrome 浏览器 ---"
OS_TYPE="unknown"
case "$(uname -s)" in
  Darwin*)  OS_TYPE="macos" ;;
  Linux*)   OS_TYPE="linux" ;;
esac

CHROME_PATH=""
case "$OS_TYPE" in
  macos)
    if [ -d "/Applications/Google Chrome.app" ]; then
      CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
      echo "  ✅ Chrome (macOS)"
      ((PASS++))
    else
      echo "  ❌ Chrome 未安装"
      ((FAIL++))
    fi
    ;;
  linux)
    if command -v google-chrome &>/dev/null || command -v google-chrome-stable &>/dev/null; then
      echo "  ✅ Chrome (Linux)"
      ((PASS++))
    else
      echo "  ❌ Chrome 未安装"
      ((FAIL++))
    fi
    ;;
esac

echo ""
echo "--- CDP 端口 9222 ---"
# Check if port 9222 is in use (Chrome running in CDP mode)
if command -v lsof &>/dev/null; then
  if lsof -i :9222 &>/dev/null; then
    echo "  ✅ Chrome 已在 CDP 模式运行 (端口 9222)"
    ((PASS++))
  else
    echo "  ⚠️  Chrome 未以 CDP 模式运行"
    echo ""
    echo "  请执行以下命令启动 Chrome："
    if [ "$OS_TYPE" = "macos" ]; then
      echo "    /Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome --remote-debugging-port=9222 &"
    else
      echo "    google-chrome --remote-debugging-port=9222 &"
    fi
    echo ""
    echo "  启动后在 Chrome 中登录 https://h.liepin.com"
    ((WARN++))
  fi
else
  echo "  ⚠️  无法检测 CDP 端口（缺少 lsof 命令）"
  ((WARN++))
fi

echo ""
echo "--- 猎聘登录状态 ---"
echo "  请确认 Chrome 中已登录猎聘账号 (https://h.liepin.com)"
echo "  可通过以下命令验证："
echo "    agent-browser --cdp 9222 goto https://h.liepin.com"
((WARN++))

echo ""
echo "========================================="
echo "  检测结果: ✅ $PASS 通过  ❌ $FAIL 失败  ⚠️  $WARN 警告"
echo "========================================="

if [ "$FAIL" -gt 0 ]; then
  echo ""
  echo "请先修复失败项后再使用此 skill。"
  exit 1
fi

echo ""
echo "环境检测通过！可以开始使用猎聘候选人搜索 skill。"
