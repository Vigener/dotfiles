# ==============================================================================
# Mikoto Igarashi - Universal .zshrc (Mac/WSL/Linux Compatible)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. OS Detection & Homebrew Setup (OS自動判定とBrewのパス設定)
# ------------------------------------------------------------------------------
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS (Apple Silicon)
    export HOMEBREW_PREFIX="/opt/homebrew"
elif [[ "$(uname)" == "Linux" ]]; then
    # WSL / Linux
    export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
    # WSL固有の設定
    export BROWSER=wslview
fi

# Homebrewの初期化 (1回だけ実行)
if [[ -x "${HOMEBREW_PREFIX}/bin/brew" ]]; then
    eval "$(${HOMEBREW_PREFIX}/bin/brew shellenv)"
    export HOMEBREW_NO_AUTO_UPDATE=1
fi

# ------------------------------------------------------------------------------
# 2. Oh My Zsh Configuration (OMZ設定 - 不要なコメントを排除し最小化)
# ------------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="ys"

# HPC/開発効率を高めるプラグイン群
# ※ zsh-autosuggestions, zsh-syntax-highlighting は $ZSH_CUSTOM/plugins に別途クローンが必要
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

autoload -Uz compinit && compinit -u
setopt hist_ignore_dups
setopt auto_cd

source $ZSH/oh-my-zsh.sh

# ------------------------------------------------------------------------------
# 3. Environment Variables & Paths (環境変数とパス設定)
# ------------------------------------------------------------------------------
# 言語設定 (UTF-8の明示化)
export LANG=en_US.UTF-8

# Cargo (Rust) / Local bin
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

# エディタのデフォルト設定
export EDITOR='nvim'

# ------------------------------------------------------------------------------
# 4. Aliases & Functions (エイリアスとカスタム関数)
# ------------------------------------------------------------------------------
# エディタ系
alias nv="nvim"
alias em="emacs -nw"

# ディレクトリ移動系 (ghq連携)
# 以前のunivエイリアスは環境依存だったため、Mac/WSL共通の ~/univ 等が存在する場合のみ移動する関数に
function univ() {
    if [[ -d "$HOME/univ" ]]; then
        cd "$HOME/univ"
    else
        echo "Directory $HOME/univ does not exist on this machine."
    fi
}

# ------------------------------------------------------------------------------
# 5. Toolchain & Integrations (外部ツールの初期化)
# ------------------------------------------------------------------------------
# Mise (バージョン管理ツール)
if command -v mise >/dev/null; then
    eval "$(mise activate zsh)"
fi

# ------------------------------------------------------------------------------
# 6. SSH Agent Configuration (SSHエージェントの自動起動)
# ------------------------------------------------------------------------------
if [[ "$(uname)" == "Linux" ]]; then
    # WSL/DevContainers用の手動エージェント起動
    if [ -z "$SSH_AUTH_SOCK" ]; then
        eval "$(ssh-agent -s)" > /dev/null
        if [ -f ~/.ssh/id_ed25519_github_thinkpad ]; then
            ssh-add ~/.ssh/id_ed25519_github_thinkpad 2>/dev/null
        fi
    fi
else
    # macOSの場合は、~/.ssh/config で UseKeychain yes を設定することを推奨
    # (ここでは余計なバックグラウンドプロセスを起動させない)
fi

# ------------------------------------------------------------------------------
# 7. Machine Specific Overrides (マシン固有のローカル設定読み込み)
# ------------------------------------------------------------------------------
# dotfilesで管理しない、このPCだけの秘密情報や特殊設定は .zshrc.local に書く
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# -----------------------------
# ghq + fzf integration (Repository Jump)
# -----------------------------
function ghq_fzf_cd() {
    # ghqで管理しているリポジトリ一覧を取得し、fzfで絞り込み（プレビュー付き）
    local selected_repo=$(ghq list | fzf --prompt="Git Repo > " --preview="ls -lah $(ghq root)/{}")
    
    # リポジトリが選択された場合のみcdコマンドを実行
    if [ -n "$selected_repo" ]; then
        BUFFER="cd $(ghq root)/${selected_repo}"
        zle accept-line
    fi
    zle reset-prompt
}

# Zshのラインエディタ(zle)に自作関数をウィジェットとして登録
zle -N ghq_fzf_cd

# Ctrl + ] (コントロールキーと右ブラケット) に割り当て
bindkey '^]' ghq_fzf_cd


# -----------------------------
# ghq + fzf integration for Warp (Command approach)
# -----------------------------
function cdg() {
    # ghqで管理しているリポジトリ一覧を取得し、fzfで絞り込み
    local selected_repo=$(ghq list | fzf --prompt="Git Repo > " --preview="ls -lah $(ghq root)/{}")
    
    # リポジトリが選択された場合のみcdコマンドを実行
    if [ -n "$selected_repo" ]; then
        cd "$(ghq root)/${selected_repo}"
        # Warpのブロックに出力として分かりやすく表示させる
        echo "🚀 Jumped to: $(pwd)"
    fi
}
