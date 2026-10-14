#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title AI Usage (Antigravity & Cursor)
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🧠
# @raycast.packageName AI Tools

# Documentation:
# @raycast.description Show detailed AI quota and usage for Antigravity and Cursor

export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$HOME/bin:$PATH"

SCRIPT_PATH=""
for p in "$HOME/dotfiles/bin/update-ai-usage" "$HOME/ghq/github.com/Vigener/dotfiles/bin/update-ai-usage" "$HOME/.local/bin/update-ai-usage"; do
  if [[ -x "$p" ]]; then
    SCRIPT_PATH="$p"
    break
  fi
done

if [[ -n "$SCRIPT_PATH" ]]; then
  "$SCRIPT_PATH" --format markdown
else
  echo "Error: update-ai-usage script not found."
  exit 1
fi
