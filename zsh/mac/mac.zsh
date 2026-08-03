# ==============================================================================
# Mac Specific Zsh Configuration
# ==============================================================================

# Homebrew
export HOMEBREW_PREFIX="/opt/homebrew"

# ==========================================
# Remote Execution (SSH)
# ==========================================
# 汎用リモート実行 (e.g., on thinkpad docker ps / on mini hostname)
on() {
  local target="$1"
  shift
  ssh -t "$target" "$@"
}

# ThinkPad（保険・Linux）: Zellij
# herdr はエイリアスを置かず `herdr` / `herdr --remote mini` 等をそのまま使う
th-zj() {
  if [ -z "$1" ]; then
    ssh -t thinkpad '/home/mikoto/.local/bin/zellij attach -c main'
  else
    ssh -t thinkpad "/home/mikoto/.local/bin/zellij attach -c '$1'"
  fi
}
