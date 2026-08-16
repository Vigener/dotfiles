#!/usr/bin/env bash
# Selective symlink deploy for macOS (MBA / Mac mini). No Stow.
# Usage: ~/dotfiles/bin/link-dotfiles-macos.sh
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
if [[ ! -d "$DOTFILES" ]]; then
  echo "error: DOTFILES not found: $DOTFILES" >&2
  exit 1
fi

backup() {
  local path="$1"
  if [[ -e "$path" || -L "$path" ]]; then
    if [[ -L "$path" ]]; then
      local target
      target=$(readlink "$path" || true)
      # already correct link — skip
      if [[ "$target" == "$2" || "$target" == "$DOTFILES/"* ]]; then
        # still rewrite with ln -sfn below for absolute consistency
        :
      fi
    elif [[ -f "$path" ]]; then
      local bak="${path}.stub.bak"
      if [[ ! -e "$bak" ]]; then
        mv "$path" "$bak"
        echo "backed up: $path -> $bak"
      else
        mv "$path" "${path}.bak.$(date +%Y%m%d%H%M%S)"
        echo "backed up: $path (timestamped)"
      fi
    else
      echo "error: refusing to replace non-file: $path" >&2
      exit 1
    fi
  fi
}

link_file() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ ! -e "$src" ]]; then
    echo "error: missing source: $src" >&2
    exit 1
  fi
  # If dest is a real file/dir, backup first
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    backup "$dest" "$src"
  fi
  ln -sfn "$src" "$dest"
  echo "link: $dest -> $src"
}

echo "==> linking from $DOTFILES"

link_file "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
# .zprofile: intentionally not linked (machine-local brew shellenv / OrbStack)

link_file "$DOTFILES/herdr/.config/herdr/config.toml" "$HOME/.config/herdr/config.toml"
link_file "$DOTFILES/ghostty/.config/ghostty/config" "$HOME/.config/ghostty/config"
# MBA only: initial-command. Never overwrite an existing local file.
if [[ -d /Applications/Ghostty.app ]]; then
  local_cfg="$HOME/.config/ghostty/config.local"
  example="$DOTFILES/ghostty/.config/ghostty/config.local.mba.example"
  if [[ ! -e "$local_cfg" ]]; then
    cp "$example" "$local_cfg"
    echo "created: $local_cfg (MBA initial-command; not a symlink)"
  else
    echo "keep: $local_cfg (machine-local)"
  fi
fi
link_file "$DOTFILES/rtk/config.toml" "$HOME/Library/Application Support/rtk/config.toml"
link_file "$DOTFILES/mise/config.toml" "$HOME/.config/mise/config.toml"
link_file "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"
link_file "$DOTFILES/git/.gitignore_global" "$HOME/.gitignore_global"
link_file "$DOTFILES/nvim/.config/nvim" "$HOME/.config/nvim"

mkdir -p "$HOME/.cursor"
link_file "$DOTFILES/agents/skills" "$HOME/.cursor/skills"
link_file "$DOTFILES/agents/rules/cursorrules" "$HOME/.cursorrules"

if command -v git >/dev/null; then
  git config --global core.excludesfile "$HOME/.gitignore_global"
  echo "git: core.excludesfile=$HOME/.gitignore_global"
fi

echo "==> done (selective links; Stow not used)"
echo "note: Oh My Zsh expected at ~/.oh-my-zsh until .zshrc is slimmed"
echo "note: herdr links config.toml only (not the whole ~/.config/herdr dir)"
echo "note: ghostty links config; config.local is MBA-only and not a symlink"
echo "note: rtk links config.toml only (macOS Application Support path)"
