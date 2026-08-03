# ==============================================================================
# Mac Specific Zsh Configuration
# ==============================================================================

# Homebrew
export HOMEBREW_PREFIX="/opt/homebrew"

# ==========================================
# Remote Execution (SSH)
# ==========================================
# 汎用リモート実行 (e.g., on thinkpad docker ps / on mini hostname)
# herdr / zellij の短縮は置かない（コマンドをそのまま打つ）
on() {
  local target="$1"
  shift
  ssh -t "$target" "$@"
}
