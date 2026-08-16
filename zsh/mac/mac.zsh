# ==============================================================================
# Mac Specific Zsh Configuration
# ==============================================================================

# Homebrew
export HOMEBREW_PREFIX="/opt/homebrew"

# herdr --remote は、フラグなしだと client を HERDR_REMOTE_KEYBINDINGS=local で
# 起動する（親の env を上書きする）。plugin_action は MBA に無くて消える。
# 関数で server を付ける。明示的に --remote-keybindings local と書けばそのまま。
herdr() {
  local remote=0 kb=0 a
  for a in "$@"; do
    case "$a" in
      --remote|--remote=*) remote=1 ;;
      --remote-keybindings|--remote-keybindings=*) kb=1 ;;
    esac
  done
  if (( remote && ! kb )); then
    command herdr --remote-keybindings server "$@"
  else
    command herdr "$@"
  fi
}
