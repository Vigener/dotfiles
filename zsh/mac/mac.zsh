# ==============================================================================
# Mac Specific Zsh Configuration
# ==============================================================================

# Homebrew
export HOMEBREW_PREFIX="/opt/homebrew"

# ==========================================
# Remote Execution (SSH Wrappers to Thinkpad)
# ==========================================
# 汎用リモート実行コマンド (e.g., on thinkpad docker ps)
on() {
  local target="$1"
  shift
  ssh -t "$target" "$@"
}

# Zellij への最速アクセス用プレフィックス関数
th-zj() {
  if [ -z "$1" ]; then
    ssh -t thinkpad '/home/mikoto/.local/bin/zellij attach -c main'
  else
    ssh -t thinkpad "/home/mikoto/.local/bin/zellij attach -c '$1'"
  fi
}

# herdr への最速アクセス用プレフィックス関数
th-hd() {
  if [ -z "$1" ]; then
    ssh -t thinkpad '/home/mikoto/.local/bin/herdr'
  else
    ssh -t thinkpad "/home/mikoto/.local/bin/herdr session attach '$1'"
  fi
}
