# ==============================================================================
# Thinkpad (Linux/WSL) Specific Zsh Configuration
# ==============================================================================

# Homebrew
export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"

# WSL固有の設定
export BROWSER=wslview

# ==========================================
# SSH Agent Configuration
# ==========================================
# WSL/DevContainers用の手動エージェント起動
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
    if [ -f ~/.ssh/id_ed25519_github_thinkpad ]; then
        ssh-add ~/.ssh/id_ed25519_github_thinkpad 2>/dev/null
    fi
fi

# ==========================================
# Custom Aliases & Overrides
# ==========================================
# tmux 独自ラッパは置かない（tmux ls / attach をそのまま使う）

# ==========================================
# Zellij wrapper
# ==========================================
zj() {
  if [ -z "$1" ]; then
    zellij attach -c main
  else
    zellij attach -c "$1"
  fi
}

zjk() {
  local session
  session=$(zellij list-sessions -n 2>/dev/null | fzf --exit-0 --prompt="Kill Zellij Session> ")
  
  if [ -n "$session" ]; then
    zellij kill-session "$session"
    echo "💀 Killed Zellij session: $session"
  fi
}

zjl() {
  local session
  session=$(zellij list-sessions -n 2>/dev/null | fzf --exit-0 --prompt="Attach Zellij Session> ")
  
  if [ -n "$session" ]; then
    zellij attach -c "$session"
  fi
}

# ==========================================
# VSCode Remote Spot-Summoning Alias
# ==========================================
code() {
    MAC_IP=$(echo $SSH_CLIENT | awk '{print $1}')
    MAC_USER="mikoto"
    if [ -z "$1" ]; then
        TARGET_DIR=$(pwd)
    else
        TARGET_DIR=$(realpath "$1")
    fi
    # Execute 'code' command on Mac to open this remote directory
    ssh -o StrictHostKeyChecking=no $MAC_USER@$MAC_IP "/usr/local/bin/code --folder-uri vscode-remote://ssh-remote+thinkpad$TARGET_DIR"
}

