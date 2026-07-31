#!/usr/bin/env bash
# Cursor stop hook: opt-in open-artifact.
# Only runs if ~/.cursor/open-on-stop.url exists (single-line URL).
# Never blocks the agent stop path.
set -u

marker="${HOME}/.cursor/open-on-stop.url"
(
  if [[ -f "$marker" ]]; then
    url="$(tr -d '[:space:]' <"$marker")"
    if [[ "$url" == http://* || "$url" == https://* ]]; then
      ssh -o BatchMode=yes -o ConnectTimeout=5 mac "open $(printf %q "$url")" >/dev/null 2>&1 || true
    fi
    # one-shot
    rm -f "$marker"
  fi
) >/dev/null 2>&1 &

printf '%s\n' '{}'
exit 0
