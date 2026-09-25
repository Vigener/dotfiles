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

# mini のシェルから MBA の Cursor IDE を Remote SSH で開く。
# 確認済み（Cursor 3.17 / MBA）:
#   /opt/homebrew/bin/cursor editor -n --classic --folder-uri "vscode-remote://ssh-remote+mini<abs-path>"
# MBA では定義しない（Darwin 共通のこのファイルでも hostname で分岐）。
if [[ "$(scutil --get LocalHostName 2>/dev/null)" == "mikoto-mac-mini" ]]; then
  cursor() {
    if [[ -n "${VSCODE_IPC_HOOK_CLI:-}" ]]; then
      command cursor "$@"
      return
    fi
    case "${1:-}" in
      agent|editor|tunnel|--help|-h|--version|-v)
        command cursor "$@"
        return
        ;;
    esac
    local target
    if (( $# == 0 )) || [[ "$1" == "." ]]; then
      target="$PWD"
    else
      target="$1"
    fi
    target="$(realpath "$target")" || return
    local uri="vscode-remote://ssh-remote+mini${target}"
    ssh mac "/opt/homebrew/bin/cursor editor -n --classic --folder-uri $(printf %q "$uri")"
  }
fi
