# Universal .zshrc (macOS / Linux) — OMZ なし、ラッパ最小
# 機種別: mac/mac.zsh | thinkpad/thinkpad.zsh | 秘密・機種のみ: ~/.zshrc.local

# --- OS / Homebrew ---
if [[ "$(uname)" == "Darwin" ]]; then
  [ -f ~/dotfiles/zsh/mac/mac.zsh ] && source ~/dotfiles/zsh/mac/mac.zsh
elif [[ "$(uname)" == "Linux" ]]; then
  [ -f ~/dotfiles/zsh/thinkpad/thinkpad.zsh ] && source ~/dotfiles/zsh/thinkpad/thinkpad.zsh
fi
if [[ -x "${HOMEBREW_PREFIX}/bin/brew" ]]; then
  eval "$(${HOMEBREW_PREFIX}/bin/brew shellenv)"
  export HOMEBREW_NO_AUTO_UPDATE=1
fi

# --- core ---
autoload -Uz compinit && compinit -u
setopt hist_ignore_dups auto_cd
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

export LANG=en_US.UTF-8
export EDITOR='nvim'
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$HOME/bin:$HOME/local/bin:$PATH"
[[ -d "$HOME/superset/bin" ]] && export PATH="$HOME/superset/bin:$PATH"

alias nv='nvim'
alias em='emacs -nw'

# --- tools ---
command -v mise >/dev/null && eval "$(mise activate zsh)"
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
command -v direnv >/dev/null && eval "$(direnv hook zsh)"
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# ghq + fzf → リポへ cd
cdg() {
  local selected_repo
  selected_repo=$(ghq list | fzf --prompt='Git Repo > ' --preview="ls -lah $(ghq root)/{}")
  if [[ -n "$selected_repo" ]]; then
    cd "$(ghq root)/${selected_repo}"
    echo "Jumped to: $(pwd)"
  fi
}

vibe-add() {
  if [[ "$#" -ne 2 ]]; then
    echo "Usage: vibe-add <from> <to>"
    return 1
  fi
  local vocab_file="$HOME/.config/vibe-dictator/vocabulary.json"
  jq --arg f "$1" --arg t "$2" '.preferred_terms += [{"from": $f, "to": $t}]' \
    "$vocab_file" > "${vocab_file}.tmp" && mv "${vocab_file}.tmp" "$vocab_file"
  echo "added: $1 -> $2"
}

# --- prompt + plugins (syntax-highlighting last) ---
_ghq_root="${GHQ_ROOT:-}"
[[ -z "$_ghq_root" ]] && command -v ghq >/dev/null && _ghq_root="$(ghq root 2>/dev/null)"
_ghq_root="${_ghq_root:-$HOME/ghq}"

[[ -f "$_ghq_root/github.com/zsh-users/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
  source "$_ghq_root/github.com/zsh-users/zsh-autosuggestions/zsh-autosuggestions.zsh"
command -v starship >/dev/null && eval "$(starship init zsh)"
[[ -f "$_ghq_root/github.com/zsh-users/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
  source "$_ghq_root/github.com/zsh-users/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
unset _ghq_root
