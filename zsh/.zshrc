# ==============================================================================
# Mikoto Igarashi - Universal .zshrc (Mac/WSL/Linux Compatible)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. OS Detection & Local Config Load (環境別設定の読み込み)
# ------------------------------------------------------------------------------
if [[ "$(uname)" == "Darwin" ]]; then
    [ -f ~/dotfiles/zsh/mac/mac.zsh ] && source ~/dotfiles/zsh/mac/mac.zsh
elif [[ "$(uname)" == "Linux" ]]; then
    [ -f ~/dotfiles/zsh/thinkpad/thinkpad.zsh ] && source ~/dotfiles/zsh/thinkpad/thinkpad.zsh
fi

# Homebrewの初期化 (1回だけ実行)
if [[ -x "${HOMEBREW_PREFIX}/bin/brew" ]]; then
    eval "$(${HOMEBREW_PREFIX}/bin/brew shellenv)"
    export HOMEBREW_NO_AUTO_UPDATE=1
fi

# ------------------------------------------------------------------------------
# 2. Zsh core (OMZ なし — 見た目は Starship、補助は ghq 上の2プラグイン)
# ------------------------------------------------------------------------------
autoload -Uz compinit && compinit -u
setopt hist_ignore_dups
setopt auto_cd

# 大文字小文字を区別せずに補完する (cd de -> Desktop)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
# ------------------------------------------------------------------------------
# 3. Environment Variables & Paths (環境変数とパス設定)
# ------------------------------------------------------------------------------
# 言語設定 (UTF-8の明示化)
export LANG=en_US.UTF-8

# Cargo (Rust) / Local bin
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$HOME/bin:$PATH"

# エディタのデフォルト設定
export EDITOR='nvim'

# ------------------------------------------------------------------------------
# 4. Aliases & Functions (エイリアスとカスタム関数)
# ------------------------------------------------------------------------------
# エディタ系
alias nv="nvim"
alias em="emacs -nw"

alias rb-push='make -C ~/brain rb-day-update'
alias lb-push='make -C ~/brain lb-day-update'
alias rb-init='make -C ~/brain rb-init-day'
alias lb-init='make -C ~/brain lb-init-day'
alias brain-push='make -C ~/brain day-update'
alias brain-init='make -C ~/brain init-day'

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

# ==========================================
# CLI Cockpit Setup (tmux + btm)
# ==========================================
function cockpit() {
    # 'cockpit' という名前のtmuxセッションが既に存在するかチェック
    tmux has-session -t cockpit 2>/dev/null

    # 存在しない場合（$? != 0）は新規作成してレイアウトを構築
    if [ $? != 0 ]; then
        # 新規セッションを作成（-dでバックグラウンド起動）
        tmux new-session -d -s cockpit

        # 左ペイン（ペイン0）で bottom (btm) を起動
        tmux send-keys -t cockpit:0 'btm' C-m

        # 画面を左右に分割（右にペイン1を作成、幅は全体の45%とする）
        tmux split-window -h -t cockpit:0 -p 45

        # 右ペイン（ペイン1）にウェルカムメッセージを表示（モチベーション用）
        tmux send-keys -t cockpit:1 'echo "HPC Cockpit Online. Ready for execution."' C-m
    fi

    # 構築済み、または既存のセッションにアタッチして画面に表示
    tmux attach-session -t cockpit
}

# 8. direnv Integration (direnvの初期化)
eval "$(direnv hook zsh)"

function vibe-add() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: vibe-add <from> <to>"
    echo "Example: vibe-add カラビナ Karabiner-Elements"
    return 1
  fi

  local vocab_file="$HOME/.config/vibe-dictator/vocabulary.json"
  jq --arg f "$1" --arg t "$2" '.preferred_terms += [{"from": $f, "to": $t}]' "$vocab_file" > "${vocab_file}.tmp" && mv "${vocab_file}.tmp" "$vocab_file"
  echo "✅ 辞書に追加しました: $1 -> $2"
}
export PATH=$HOME/local/bin:$PATH

# zoxide
eval "$(zoxide init zsh)"

# ==========================================
# tmux wrapper
# ==========================================
tm() {
  if [ -z "$1" ]; then
    tmux new-session -A -s default
  else
    tmux new-session -A -s "$1"
  fi
}

tmk() {
  local session
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0 --prompt="Kill Session> ")

  if [ -n "$session" ]; then
    tmux kill-session -t "$session"
    echo "💀 Killed session: $session"
  fi
}

alias tml='tmux ls'

# Superset CLI (ThinkPad 等にパスがあるときだけ)
[[ -d "$HOME/superset/bin" ]] && export PATH="$HOME/superset/bin:$PATH"

# ------------------------------------------------------------------------------
# Prompt + zsh plugins (ghq). syntax-highlighting は最後。
# clone: ghq get https://github.com/zsh-users/zsh-autosuggestions
#        ghq get https://github.com/zsh-users/zsh-syntax-highlighting
# ------------------------------------------------------------------------------
_ghq_root="${GHQ_ROOT:-}"
if [[ -z "$_ghq_root" ]] && command -v ghq >/dev/null; then
  _ghq_root="$(ghq root 2>/dev/null)"
fi
_ghq_root="${_ghq_root:-$HOME/ghq}"

[[ -f "$_ghq_root/github.com/zsh-users/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
  source "$_ghq_root/github.com/zsh-users/zsh-autosuggestions/zsh-autosuggestions.zsh"

if command -v starship >/dev/null; then
  eval "$(starship init zsh)"
fi

[[ -f "$_ghq_root/github.com/zsh-users/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
  source "$_ghq_root/github.com/zsh-users/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

unset _ghq_root
