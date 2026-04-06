#!/usr/bin/env bash
set -euo pipefail

# Ensure common install paths are in PATH throughout the script
export PATH="$HOME/.local/bin:$HOME/.claude/bin:/usr/local/bin:$PATH"

# ============================================================================
# Claude Code Universal Installer — Worxphere Edition
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/seokmogu/oh-my-worxphere/main/scripts/install-claude.sh | bash
#
# Supports: macOS (Intel/Apple Silicon), Linux (Ubuntu/Debian/Fedora), WSL2
#
# Installs:
#   1. Prerequisites: Homebrew (macOS/Linux), Node.js 22, Git, Python 3.12+
#   2. Editors: VSCode, Ghostty, Zed
#   3. Claude Code CLI + oh-my-worxphere plugin
#   4. Chrome extension guidance
# ============================================================================

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
DIM='\033[2m'
NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()      { echo -e "${GREEN}[ OK ]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
fail()    { echo -e "${RED}[FAIL]${NC} $*"; exit 1; }
step()    { echo -e "\n${BOLD}══ $* ══${NC}"; }
substep() { echo -e "  ${DIM}→${NC} $*"; }

OS=""
ARCH=""
PKG=""
INSTALLED=()
SKIPPED=()
FAILED=()

# ─────────────────────────────────────────────────────────────────────────────
# OS / Architecture Detection
# ─────────────────────────────────────────────────────────────────────────────
detect_os() {
  step "Detecting Environment"

  ARCH="$(uname -m)"
  local uname_s
  uname_s="$(uname -s)"

  case "$uname_s" in
    Darwin)
      OS="macos"
      PKG="brew"
      ;;
    Linux)
      if grep -qi microsoft /proc/version 2>/dev/null; then
        OS="wsl"
      else
        OS="linux"
      fi
      if command -v apt-get &>/dev/null; then
        PKG="apt"
      elif command -v dnf &>/dev/null; then
        PKG="dnf"
      else
        PKG="unknown"
      fi
      ;;
    MINGW*|MSYS*|CYGWIN*)
      echo ""
      echo -e "${RED}Windows (non-WSL) detected.${NC}"
      echo -e "이 스크립트는 WSL2 환경에서 실행해야 합니다."
      echo ""
      echo -e "${BOLD}WSL2 설치 방법:${NC}"
      echo -e "  1. PowerShell(관리자)에서: ${CYAN}wsl --install -d Ubuntu-24.04${NC}"
      echo -e "  2. PC 재부팅"
      echo -e "  3. Ubuntu 터미널에서 이 스크립트를 다시 실행"
      echo ""
      echo -e "또는 PowerShell 자동 설치 스크립트를 사용하세요:"
      echo -e "  ${CYAN}irm https://raw.githubusercontent.com/seokmogu/oh-my-worxphere/main/scripts/install-windows.ps1 | iex${NC}"
      exit 1
      ;;
    *)
      fail "Unsupported OS: $uname_s"
      ;;
  esac

  ok "OS: $OS ($ARCH), Package Manager: $PKG"
}

# ─────────────────────────────────────────────────────────────────────────────
# Utility
# ─────────────────────────────────────────────────────────────────────────────
has() { command -v "$1" &>/dev/null; }

track() {
  local name="$1" status="$2"
  case "$status" in
    ok)      INSTALLED+=("$name") ;;
    skip)    SKIPPED+=("$name") ;;
    fail)    FAILED+=("$name") ;;
  esac
}

# ─────────────────────────────────────────────────────────────────────────────
# Homebrew (macOS + Linux)
# ─────────────────────────────────────────────────────────────────────────────
install_brew() {
  if has brew; then
    substep "Homebrew already installed"
    return
  fi

  case "$OS" in
    macos|linux|wsl)
      info "Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

      # Add to PATH for current session
      if [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      elif [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      fi
      ;;
  esac
}

# ─────────────────────────────────────────────────────────────────────────────
# Step 1: Prerequisites
# ─────────────────────────────────────────────────────────────────────────────
install_prerequisites() {
  step "Step 1: Prerequisites"

  # Linux/WSL: install essential tools via apt FIRST (Homebrew needs Git)
  if [[ "$PKG" == "apt" ]]; then
    substep "Installing essential packages via apt..."
    sudo apt-get update -qq
    sudo apt-get install -y git curl build-essential 2>/dev/null
  fi

  # Homebrew (macOS only — Linux uses apt/NodeSource directly)
  if [[ "$OS" == "macos" ]]; then
    install_brew
  fi

  # Git
  if has git; then
    ok "Git $(git --version | awk '{print $3}')"
    track "Git" ok
  else
    substep "Installing Git..."
    case "$PKG" in
      brew) brew install git ;;
      apt)  sudo apt-get install -y git ;;
      dnf)  sudo dnf install -y git ;;
    esac
    has git && { ok "Git installed"; track "Git" ok; } || { warn "Git install failed"; track "Git" fail; }
  fi

  # Python 3.12+
  local py_ver=""
  if has python3; then
    py_ver="$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")' 2>/dev/null || echo "0.0")"
  fi

  if [[ "$(echo "$py_ver >= 3.12" | bc -l 2>/dev/null || echo 0)" == "1" ]]; then
    ok "Python $py_ver"
    track "Python" ok
  else
    substep "Installing Python 3.12+..."
    case "$PKG" in
      brew) brew install python@3.12 ;;
      apt)  sudo apt-get install -y python3.12 python3.12-venv ;;
      dnf)  sudo dnf install -y python3.12 ;;
    esac
    has python3 && { ok "Python installed"; track "Python" ok; } || { warn "Python install failed"; track "Python" fail; }
  fi

  # Node.js 22
  if has node; then
    local node_major
    node_major="$(node --version | sed 's/v//' | cut -d. -f1)"
    if [ "$node_major" -ge 18 ]; then
      ok "Node.js $(node --version)"
      track "Node.js" ok
    else
      warn "Node.js $(node --version) too old, upgrading..."
      _install_node
    fi
  else
    _install_node
  fi

  # uv (Python package manager)
  if has uv; then
    ok "uv $(uv --version 2>/dev/null | awk '{print $2}')"
    track "uv" ok
  else
    substep "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
    has uv && { ok "uv installed"; track "uv" ok; } || { warn "uv install failed"; track "uv" fail; }
  fi
}

_install_node() {
  substep "Installing Node.js 22..."
  case "$OS" in
    macos)
      brew install node@22
      ;;
    linux|wsl)
      if [[ "$PKG" == "apt" ]]; then
        curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
        sudo apt-get install -y nodejs
      elif [[ "$PKG" == "dnf" ]]; then
        curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -
        sudo dnf install -y nodejs
      fi
      ;;
  esac
  has node && { ok "Node.js $(node --version)"; track "Node.js" ok; } || { warn "Node.js install failed"; track "Node.js" fail; }
}

# ─────────────────────────────────────────────────────────────────────────────
# Step 2: Editors (VSCode, Ghostty, Zed)
# ─────────────────────────────────────────────────────────────────────────────
install_editors() {
  step "Step 2: Editors"

  # Skip editors in headless/container environments
  if [[ -f /.dockerenv ]] || [[ -f /run/.containerenv ]] || [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" && "$OS" != "macos" ]]; then
    warn "Headless environment detected — skipping editor installation"
    track "VSCode" skip
    track "Ghostty" skip
    track "Zed" skip
    return
  fi

  # VSCode
  if has code; then
    ok "VSCode already installed"
    track "VSCode" ok
  else
    substep "Installing VSCode..."
    case "$OS" in
      macos)
        brew install --cask visual-studio-code
        ;;
      linux|wsl)
        if [[ "$PKG" == "apt" ]]; then
          curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /etc/apt/keyrings/packages.microsoft.gpg 2>/dev/null
          echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
          sudo apt-get update -qq
          sudo apt-get install -y code 2>/dev/null
        else
          warn "VSCode: Install manually from https://code.visualstudio.com"
        fi
        ;;
    esac
    has code && { ok "VSCode installed"; track "VSCode" ok; } || { warn "VSCode: manual install needed"; track "VSCode" skip; }
  fi

  # Ghostty
  if has ghostty; then
    ok "Ghostty already installed"
    track "Ghostty" ok
  else
    substep "Installing Ghostty..."
    case "$OS" in
      macos)
        brew install --cask ghostty
        ;;
      linux|wsl)
        # Ghostty on Linux: build from source or use package if available
        if [[ "$PKG" == "apt" ]]; then
          # Try snap or flatpak first
          if has snap; then
            sudo snap install ghostty 2>/dev/null || warn "Ghostty snap not available"
          fi
        fi
        if ! has ghostty; then
          warn "Ghostty: Linux 설치는 https://ghostty.org/docs/install 참고"
        fi
        ;;
    esac
    has ghostty && { ok "Ghostty installed"; track "Ghostty" ok; } || { warn "Ghostty: manual install may be needed"; track "Ghostty" skip; }
  fi

  # Zed
  if has zed; then
    ok "Zed already installed"
    track "Zed" ok
  else
    substep "Installing Zed..."
    case "$OS" in
      macos)
        brew install --cask zed
        ;;
      linux|wsl)
        curl -fsSL https://zed.dev/install.sh | sh
        ;;
    esac
    has zed && { ok "Zed installed"; track "Zed" ok; } || { warn "Zed: manual install may be needed"; track "Zed" skip; }
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Step 3: Claude Code CLI
# ─────────────────────────────────────────────────────────────────────────────
install_claude() {
  step "Step 3: Claude Code CLI"

  if has claude; then
    ok "Claude Code $(claude --version 2>/dev/null || echo '') already installed"
    track "Claude Code" ok
    return
  fi

  substep "Installing Claude Code (official native installer)..."
  case "$OS" in
    macos|linux|wsl)
      curl -fsSL https://claude.ai/install.sh | bash
      ;;
  esac

  # Refresh PATH — official installer puts claude in ~/.local/bin
  export PATH="$HOME/.local/bin:$HOME/.claude/bin:/usr/local/bin:$PATH"
  hash -r 2>/dev/null

  has claude && { ok "Claude Code $(claude --version 2>/dev/null) installed"; track "Claude Code" ok; } || { warn "Claude Code install failed"; track "Claude Code" fail; }
}

# ─────────────────────────────────────────────────────────────────────────────
# Step 4: Login
# ─────────────────────────────────────────────────────────────────────────────
do_login() {
  step "Step 4: Claude Code Login"

  if claude auth status &>/dev/null 2>&1; then
    ok "Already logged in"
    return
  fi

  echo ""
  echo -e "  ${BOLD}Claude Code에 로그인해야 합니다.${NC}"
  echo ""

  read -rp "  지금 로그인하시겠습니까? (Y/n): " answer
  answer="${answer:-Y}"

  if [[ "$answer" =~ ^[Yy]$ ]]; then
    claude login
  else
    warn "나중에 'claude login' 을 실행하세요."
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Step 5: oh-my-worxphere Plugin
# ─────────────────────────────────────────────────────────────────────────────
install_plugin() {
  step "Step 5: oh-my-worxphere Plugin"

  substep "Adding marketplace..."
  claude plugin marketplace add https://github.com/seokmogu/oh-my-worxphere 2>/dev/null || true

  substep "Installing plugin..."
  claude plugin install oh-my-worxphere@oh-my-worxphere 2>/dev/null || true

  ok "oh-my-worxphere plugin installed"
  track "oh-my-worxphere" ok
}

# ─────────────────────────────────────────────────────────────────────────────
# Step 6: Chrome Extension Guidance
# ─────────────────────────────────────────────────────────────────────────────
chrome_extension() {
  step "Step 6: Chrome Claude Extension"

  local url="https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn"

  case "$OS" in
    macos)    open "$url" 2>/dev/null ;;
    linux)    xdg-open "$url" 2>/dev/null ;;
    wsl)      wslview "$url" 2>/dev/null || cmd.exe /c start "$url" 2>/dev/null ;;
  esac

  echo ""
  echo -e "  Chrome Web Store가 열렸습니다."
  echo -e "  ${BOLD}\"Chrome에 추가\"${NC} 버튼을 클릭하여 Claude 확장을 설치하세요."
  echo ""
  track "Chrome Extension" skip
}

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────
print_summary() {
  step "Installation Summary"
  echo ""

  for item in "${INSTALLED[@]:-}"; do
    [ -n "$item" ] && echo -e "  ${GREEN}✓${NC} $item"
  done
  for item in "${SKIPPED[@]:-}"; do
    [ -n "$item" ] && echo -e "  ${YELLOW}~${NC} $item (manual install needed)"
  done
  for item in "${FAILED[@]:-}"; do
    [ -n "$item" ] && echo -e "  ${RED}✗${NC} $item (failed)"
  done

  echo ""
  echo -e "${GREEN}${BOLD}  Setup complete!${NC}"
  echo ""
  echo -e "  ${BOLD}Next steps:${NC}"
  echo -e "  1. ${CYAN}claude${NC}              — Claude Code 시작"
  echo -e "  2. ${CYAN}/worx-onboarding${NC}    — Slack, Notion, GitLab MCP 자동 설정"
  echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────
main() {
  echo ""
  echo -e "${BOLD}╔══════════════════════════════════════════════╗${NC}"
  echo -e "${BOLD}║  Claude Code Universal Installer             ║${NC}"
  echo -e "${BOLD}║  Worxphere Edition v1.0                      ║${NC}"
  echo -e "${BOLD}╚══════════════════════════════════════════════╝${NC}"
  echo ""

  detect_os
  install_prerequisites
  install_editors
  install_claude
  do_login
  install_plugin
  chrome_extension
  print_summary
}

main "$@"
