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
link_file "$DOTFILES/zsh/.zshenv" "$HOME/.zshenv"
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

# グローバル指示ファイル: 各ハーネスの自動読込点を GLOBAL_RULES.md の単一正本へ向ける
link_file "$DOTFILES/agents/GLOBAL_RULES.md" "$HOME/.config/opencode/AGENTS.md"
link_file "$DOTFILES/agents/GLOBAL_RULES.md" "$HOME/.claude/CLAUDE.md"
link_file "$DOTFILES/agents/GLOBAL_RULES.md" "$HOME/.gemini/AGENTS.md"

mkdir -p "$HOME/.local/bin"
link_file "$DOTFILES/bin/md-to-html" "$HOME/.local/bin/md-to-html"
link_file "$DOTFILES/bin/update-ai-usage" "$HOME/.local/bin/update-ai-usage"
link_file "$DOTFILES/bin/t3-refresh" "$HOME/.local/bin/t3-refresh"

# Cursor Quota Guard (Gemini誤爆・高額モデル暴走防止)
mkdir -p "$HOME/.local/share/cursor-agent"
mkdir -p "$HOME/.cargo/bin"
link_file "$DOTFILES/bin/cursor-agent-guard" "$HOME/.local/share/cursor-agent/cursor-agent-guard"
link_file "$DOTFILES/bin/cursor-agent-guard" "$HOME/.cargo/bin/cursor-agent"
link_file "$DOTFILES/bin/cursor-agent-guard" "$HOME/.cargo/bin/agent"
link_file "$DOTFILES/bin/cursor-agent-guard" "$HOME/.local/bin/cursor-agent"
link_file "$DOTFILES/bin/cursor-agent-guard" "$HOME/.local/bin/agent" 

mkdir -p "$HOME/bin"
link_file "$DOTFILES/bin/repo-http-serve" "$HOME/bin/repo-http-serve"
link_file "$DOTFILES/bin/chrome-open-or-reload" "$HOME/bin/chrome-open-or-reload"

mkdir -p "$HOME/Library/LaunchAgents"
if [[ -f "$DOTFILES/launchd/com.vigener.ai-usage.plist" ]]; then
  link_file "$DOTFILES/launchd/com.vigener.ai-usage.plist" "$HOME/Library/LaunchAgents/com.vigener.ai-usage.plist"
fi

mkdir -p "$HOME/.gemini/config/skills"
link_file "$DOTFILES/agents/skills/md-to-html" "$HOME/.gemini/config/skills/md-to-html"

if command -v git >/dev/null; then
  git config --global core.excludesfile "$HOME/.gitignore_global"
  echo "git: core.excludesfile=$HOME/.gitignore_global"
fi

echo "==> done (selective links; Stow not used)"
echo "note: Oh My Zsh expected at ~/.oh-my-zsh until .zshrc is slimmed"
echo "note: herdr links config.toml only (not the whole ~/.config/herdr dir)"
echo "note: ghostty links config; config.local is MBA-only and not a symlink"
echo "note: rtk links config.toml only (macOS Application Support path)"
