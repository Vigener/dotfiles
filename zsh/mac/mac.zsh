# ==============================================================================
# Mac Specific Zsh Configuration
# ==============================================================================

# Homebrew
export HOMEBREW_PREFIX="/opt/homebrew"

# ==========================================
# Remote Execution (SSH / herdr)
# ==========================================
# 汎用リモート実行 (e.g., on thinkpad docker ps / on mini hostname)
on() {
  local target="$1"
  shift
  ssh -t "$target" "$@"
}

# ThinkPad（保険・Linux）: Zellij
th-zj() {
  if [ -z "$1" ]; then
    ssh -t thinkpad '/home/mikoto/.local/bin/zellij attach -c main'
  else
    ssh -t thinkpad "/home/mikoto/.local/bin/zellij attach -c '$1'"
  fi
}

# 母艦 mini: herdr（SSH でサーバ側 TUI に入る）
mi-hd() {
  if [ -z "$1" ]; then
    ssh -t mini 'herdr'
  else
    ssh -t mini "herdr session attach '$1'"
  fi
}

# 保険: ThinkPad herdr（縮退運用用）
th-hd() {
  if [ -z "$1" ]; then
    ssh -t thinkpad '/home/mikoto/.local/bin/herdr'
  else
    ssh -t thinkpad "/home/mikoto/.local/bin/herdr session attach '$1'"
  fi
}

# MBA 等からの常用: ローカルクライアント → 母艦 mini
# 同室 LAN 優先なら: alias hdr='herdr --remote mini-lan'
alias hdr='herdr --remote mini'
