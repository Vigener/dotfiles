#!/usr/bin/env bash
# Git Bash entry. Do not pass .\path to powershell (MSYS eats backslashes).
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
win="$(cygpath -w "$root/bin/link-ghostty-windows.ps1")"
exec powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$win" "$@"
