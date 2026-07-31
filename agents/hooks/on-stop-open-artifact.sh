#!/usr/bin/env bash
# Cursor stop hook: opt-in open-artifact via marker file.
# Marker: ~/.cursor/open-on-stop.url (single-line http(s) URL)
# Written by open-artifact skill when deferring open to session end.
set -u

marker="${HOME}/.cursor/open-on-stop.url"
logfile="${HOME}/.cursor/hooks/on-stop-open-artifact.log"

(
  if [[ -f "$marker" ]]; then
    url="$(tr -d '\r\n' <"$marker" | head -c 2048)"
    rm -f "$marker"
    if [[ "$url" == http://* || "$url" == https://* ]]; then
      # Single-quoted remote arg avoids double-eval of ? & in URLs
      if ssh -o BatchMode=yes -o ConnectTimeout=5 mac "open '$url'" >>"$logfile" 2>&1; then
        echo "$(date -Iseconds) OK $url" >>"$logfile"
      else
        echo "$(date -Iseconds) FAIL $url" >>"$logfile"
      fi
    fi
  fi
) >/dev/null 2>&1 &

printf '%s\n' '{}'
exit 0
