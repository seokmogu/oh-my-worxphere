# ============================================================================
# Claude Code Windows Installer — Worxphere Edition
#
# Usage (PowerShell as Administrator):
#   irm https://raw.githubusercontent.com/seokmogu/oh-my-worxphere/main/scripts/install-windows.ps1 | iex
#
# What it does:
#   1. Installs WSL2 + Ubuntu 24.04
#   2. Installs VSCode (Windows-side)
#   3. Installs Ghostty, Zed (Windows-side)
#   4. Inside WSL: runs install-claude.sh for full setup
# ============================================================================

$ErrorActionPreference = "Stop"

function Write-Step($msg)    { Write-Host "`n== $msg ==" -ForegroundColor Cyan }
function Write-Ok($msg)      { Write-Host "[OK]   $msg" -ForegroundColor Green }
function Write-Warn($msg)    { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Fail($msg)    { Write-Host "[FAIL] $msg" -ForegroundColor Red; exit 1 }
function Write-Info($msg)    { Write-Host "[INFO] $msg" -ForegroundColor Gray }

# ─────────────────────────────────────────────────────────────────────────────
# Admin check
# ─────────────────────────────────────────────────────────────────────────────
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Fail "관리자 권한으로 PowerShell을 실행하세요. (우클릭 > 관리자로 실행)"
}

Write-Host ""
Write-Host "╔══════════════════════════════════════════════╗" -ForegroundColor White
Write-Host "║  Claude Code Windows Installer               ║" -ForegroundColor White
Write-Host "║  Worxphere Edition v1.0                      ║" -ForegroundColor White
Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor White
Write-Host ""

# ─────────────────────────────────────────────────────────────────────────────
# Step 1: WSL2
# ─────────────────────────────────────────────────────────────────────────────
Write-Step "Step 1: WSL2 + Ubuntu 24.04"

$wslInstalled = $false
try {
    $wslStatus = wsl --status 2>&1
    if ($LASTEXITCODE -eq 0) {
        $wslInstalled = $true
    }
} catch {}

if ($wslInstalled) {
    # Check if Ubuntu is installed
    $distros = wsl --list --quiet 2>&1
    if ($distros -match "Ubuntu") {
        Write-Ok "WSL2 + Ubuntu already installed"
    } else {
        Write-Info "WSL2 installed but Ubuntu missing. Installing Ubuntu 24.04..."
        wsl --install -d Ubuntu-24.04 --no-launch
        Write-Ok "Ubuntu 24.04 installed. 재부팅 후 Ubuntu를 실행하여 사용자를 생성하세요."
    }
} else {
    Write-Info "Installing WSL2 + Ubuntu 24.04..."
    wsl --install -d Ubuntu-24.04

    Write-Host ""
    Write-Warn "WSL2 설치를 완료하려면 PC를 재부팅해야 합니다."
    Write-Warn "재부팅 후:"
    Write-Host "  1. Ubuntu 앱을 실행하여 사용자 생성" -ForegroundColor Cyan
    Write-Host "  2. Ubuntu 터미널에서 아래 명령어 실행:" -ForegroundColor Cyan
    Write-Host "     curl -fsSL https://raw.githubusercontent.com/seokmogu/oh-my-worxphere/main/scripts/install-claude.sh | bash" -ForegroundColor Yellow
    Write-Host ""

    $reboot = Read-Host "지금 재부팅하시겠습니까? (Y/n)"
    if ($reboot -ne "n") {
        Restart-Computer -Force
    }
    exit 0
}

# ─────────────────────────────────────────────────────────────────────────────
# Step 2: Windows-side Editors
# ─────────────────────────────────────────────────────────────────────────────
Write-Step "Step 2: Editors (Windows-side)"

# winget availability check
$hasWinget = Get-Command winget -ErrorAction SilentlyContinue

if (-not $hasWinget) {
    Write-Warn "winget이 없습니다. Microsoft Store에서 'App Installer'를 설치하세요."
    Write-Info "에디터를 수동으로 설치해야 합니다."
} else {
    # VSCode
    $hasCode = Get-Command code -ErrorAction SilentlyContinue
    if ($hasCode) {
        Write-Ok "VSCode already installed"
    } else {
        Write-Info "Installing VSCode..."
        winget install -e --id Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements
        Write-Ok "VSCode installed"
    }

    # Ghostty
    try {
        Write-Info "Installing Ghostty..."
        winget install -e --id "Ghostty.Ghostty" --accept-package-agreements --accept-source-agreements 2>$null
        Write-Ok "Ghostty installed"
    } catch {
        Write-Warn "Ghostty: https://ghostty.org/download 에서 수동 설치"
    }

    # Zed
    try {
        Write-Info "Installing Zed..."
        winget install -e --id "Zed.Zed" --accept-package-agreements --accept-source-agreements 2>$null
        Write-Ok "Zed installed"
    } catch {
        Write-Warn "Zed: https://zed.dev/download 에서 수동 설치"
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# Step 3: VSCode WSL Extension
# ─────────────────────────────────────────────────────────────────────────────
Write-Step "Step 3: VSCode WSL Extension"

$hasCode = Get-Command code -ErrorAction SilentlyContinue
if ($hasCode) {
    Write-Info "Installing WSL extension..."
    code --install-extension ms-vscode-remote.remote-wsl 2>$null
    Write-Ok "VSCode WSL extension installed"
} else {
    Write-Warn "VSCode not found, skipping extension"
}

# ─────────────────────────────────────────────────────────────────────────────
# Step 4: Run Linux installer inside WSL
# ─────────────────────────────────────────────────────────────────────────────
Write-Step "Step 4: WSL Environment Setup"

Write-Info "Running Claude Code installer inside WSL..."
wsl -d Ubuntu-24.04 -- bash -c "curl -fsSL https://raw.githubusercontent.com/seokmogu/oh-my-worxphere/main/scripts/install-claude.sh | bash"

# ─────────────────────────────────────────────────────────────────────────────
# Step 5: Chrome Extension
# ─────────────────────────────────────────────────────────────────────────────
Write-Step "Step 5: Chrome Claude Extension"

Start-Process "https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn"
Write-Host ""
Write-Host '  Chrome Web Store가 열렸습니다. "Chrome에 추가" 를 클릭하세요.' -ForegroundColor White

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────
Write-Step "Installation Complete"
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor White
Write-Host "  1. Ubuntu 터미널 열기" -ForegroundColor Cyan
Write-Host "  2. claude 실행" -ForegroundColor Cyan
Write-Host "  3. /worx-onboarding 으로 MCP 자동 설정" -ForegroundColor Cyan
Write-Host ""
