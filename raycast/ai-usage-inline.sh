#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title AI Usage
# @raycast.mode inline
# @raycast.refreshTime 5m

# Optional parameters:
# @raycast.icon 🧠
# @raycast.packageName AI Tools

# Documentation:
# @raycast.description Inline status for Antigravity, Cursor, and DeepSeek quota

export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$HOME/bin:$PATH"

SCRIPT_PATH=""
for p in "$HOME/dotfiles/bin/update-ai-usage" "$HOME/ghq/github.com/Vigener/dotfiles/bin/update-ai-usage" "$HOME/.local/bin/update-ai-usage"; do
  if [[ -x "$p" ]]; then
    SCRIPT_PATH="$p"
    break
  fi
done

if [[ -n "$SCRIPT_PATH" ]]; then
  "$SCRIPT_PATH" --format inline
else
  echo "AI Usage: script not found"
  exit 1
fi
