# ==============================================================================
# Thinkpad (Linux) Specific Zsh Configuration
# ==============================================================================

export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"

# SSH agent（鍵が未ロードのとき）
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
    if [ -f ~/.ssh/id_ed25519_github_thinkpad ]; then
        ssh-add ~/.ssh/id_ed25519_github_thinkpad 2>/dev/null
    fi
fi
