# 猎聘候选人搜索 Skill - 环境检测脚本 (Windows PowerShell)
# 运行: powershell -ExecutionPolicy Bypass -File setup.ps1

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  猎聘候选人搜索 Skill - 环境检测" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$Pass = 0
$Fail = 0
$Warn = 0

function Check-Item {
    param([string]$Name, [scriptblock]$Cmd)
    try {
        $result = & $Cmd 2>$null
        if ($result) {
            Write-Host "  [OK] $Name" -ForegroundColor Green
            $script:Pass++
            return $true
        }
    } catch {}
    Write-Host "  [X] $Name" -ForegroundColor Red
    $script:Fail++
    return $false
}

Write-Host "--- 核心依赖 ---" -ForegroundColor Yellow
Write-Host ""

# Node.js
if (Get-Command node -ErrorAction SilentlyContinue) {
    $nodeVer = node -v 2>$null
    $nodeMajor = [int]($nodeVer -replace 'v(\d+).*', '$1')
    if ($nodeMajor -ge 18) {
        Write-Host "  [OK] Node.js $nodeVer (>=18)" -ForegroundColor Green
        $Pass++
    } else {
        Write-Host "  [X] Node.js 版本过低: $nodeVer (需要 >=18)" -ForegroundColor Red
        $Fail++
    }
} else {
    Write-Host "  [X] Node.js 未安装" -ForegroundColor Red
    $Fail++
    Write-Host "      下载地址: https://nodejs.org" -ForegroundColor Gray
}

# npm
if (Get-Command npm -ErrorAction SilentlyContinue) {
    $npmVer = npm -v 2>$null
    Write-Host "  [OK] npm $npmVer" -ForegroundColor Green
    $Pass++
} else {
    Write-Host "  [X] npm 未安装" -ForegroundColor Red
    $Fail++
}

Write-Host ""
Write-Host "--- agent-browser ---" -ForegroundColor Yellow
Write-Host ""

if (Get-Command agent-browser -ErrorAction SilentlyContinue) {
    $abVer = try { agent-browser --version 2>$null } catch { "unknown" }
    Write-Host "  [OK] agent-browser ($abVer)" -ForegroundColor Green
    $Pass++
} else {
    Write-Host "  [X] agent-browser 未安装" -ForegroundColor Red
    $Fail++
    Write-Host "      安装命令: npm install -g agent-browser" -ForegroundColor Gray
    Write-Host "      如果安装失败，请手动下载 Windows 二进制文件:" -ForegroundColor Gray
    Write-Host "      https://github.com/vercel-labs/agent-browser/releases" -ForegroundColor Gray
}

Write-Host ""
Write-Host "--- Chrome 浏览器 ---" -ForegroundColor Yellow
Write-Host ""

$chromePaths = @(
    "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "${env:LocalAppData}\Google\Chrome\Application\chrome.exe"
)

$chromeFound = $false
foreach ($path in $chromePaths) {
    if (Test-Path $path) {
        Write-Host "  [OK] Chrome 已找到: $path" -ForegroundColor Green
        $chromeFound = $true
        $Pass++
        break
    }
}
if (-not $chromeFound) {
    Write-Host "  [X] Chrome 未安装" -ForegroundColor Red
    $Fail++
    Write-Host "      下载地址: https://www.google.com/chrome" -ForegroundColor Gray
}

Write-Host ""
Write-Host "--- CDP 端口 9222 ---" -ForegroundColor Yellow
Write-Host ""

$portInUse = Get-NetTCPConnection -LocalPort 9222 -State Listen -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-Host "  [OK] Chrome 已在 CDP 模式运行 (端口 9222)" -ForegroundColor Green
    $Pass++
} else {
    Write-Host "  [!] Chrome 未以 CDP 模式运行" -ForegroundColor Yellow
    $Warn++
    Write-Host ""
    Write-Host "  请按以下步骤操作：" -ForegroundColor Gray
    Write-Host "  1. 完全退出 Chrome（任务管理器确认无 chrome.exe 进程）" -ForegroundColor Gray
    Write-Host '  2. 以 CDP 模式启动 Chrome：' -ForegroundColor Gray
    Write-Host '     "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222' -ForegroundColor White
    Write-Host "  3. 在打开的 Chrome 中登录 https://h.liepin.com" -ForegroundColor Gray
}

Write-Host ""
Write-Host "--- 猎聘登录状态 ---" -ForegroundColor Yellow
Write-Host ""
Write-Host "  请确认 Chrome 中已登录猎聘账号 (https://h.liepin.com)" -ForegroundColor Gray
Write-Host '  可通过 agent-browser --cdp 9222 goto https://h.liepin.com 验证' -ForegroundColor Gray
$Warn++

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
if ($Fail -gt 0) {
    Write-Host "  检测结果: [OK] $Pass 通过  [X] $Fail 失败  [!] $Warn 警告" -ForegroundColor Red
    Write-Host ""
    Write-Host "请先修复失败项后再使用此 skill。" -ForegroundColor Red
    exit 1
} else {
    Write-Host "  检测结果: [OK] $Pass 通过  [X] $Fail 失败  [!] $Warn 警告" -ForegroundColor Green
    Write-Host ""
    Write-Host "环境检测通过！可以开始使用猎聘候选人搜索 skill。" -ForegroundColor Green
}
