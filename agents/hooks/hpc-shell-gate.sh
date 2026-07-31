#!/usr/bin/env bash
# HPC / cluster shell gate for Cursor agents.
# Threat model: agent-shaped bypasses (wrappers, -o ssh, quoted cmds, chain).
# Residuals: wiki/ai-engineering/ops_assumptions.md A8
set -u

input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.command // empty' 2>/dev/null || true)"
if [[ -z "${cmd}" ]]; then
  printf '%s\n' '{"permission":"deny","user_message":"hpc-shell-gate: parse failed","agent_message":"Use ppx_harness / miyabi_harness --dry-run."}'
  exit 0
fi

deny_msg() {
  jq -n --arg why "$1" \
    '{permission:"deny",user_message:("Blocked by hpc-shell-gate: "+$why),
      agent_message:("Use ppx_harness or miyabi_harness --dry-run. Why: "+$why)}'
}

norm="$(printf '%s' "$cmd" | tr -d "'\"\`")"
for _ in 1 2 3 4 5; do
  next="$(printf '%s' "$norm" | sed -E 's/\\([A-Za-z])/\1/g')"
  [[ "$next" == "$norm" ]] && break
  norm="$next"
done
lower="$(printf '%s' "$norm" | tr '[:upper:]' '[:lower:]')"

seg='(^|[;|&]|\$\(|&&|\|\|)'
bin='([^;|&[:space:]]*/)?'
assigns='([[:space:]]*[A-Za-z_][A-Za-z0-9_]*=[^[:space:];|&]*[[:space:]]+)*'
# NOTE: do not use ((...) in this assignment — bash parses (( as arithmetic.
wrap="${assigns}[[:space:]]*(sudo[[:space:]]+)?(command[[:space:]]+|exec[[:space:]]+|time[[:space:]]+|nice[[:space:]]+|nohup[[:space:]]+|${bin}env[[:space:]]+)*"

if printf '%s' "$lower" | grep -Eiq '(^|[^a-z])(sbatch|qsub)([^a-z]|$)'; then
  if printf '%s' "$lower" | grep -Eiq '(find[[:space:]].*-exec|xargs[[:space:]]|bash[[:space:]]*<|bash[[:space:]]*<<|<<<)'; then
    deny_msg "indirect sbatch/qsub (find/xargs/heredoc/here-string)"
    exit 0
  fi
fi

if printf '%s' "$lower" | grep -Eiq "${seg}[[:space:]]*${wrap}${bin}(bash|sh|zsh|dash)[[:space:]]+[^;|&]*-[[:alpha:]]*c" \
  && printf '%s' "$lower" | grep -Eiq '(^|[^a-z])(sbatch|qsub)([^a-z]|$)'; then
  deny_msg "shell -c embedding sbatch/qsub"
  exit 0
fi
if printf '%s' "$lower" | grep -Eiq "${bin}(bash|sh|zsh|dash)[[:space:]]+[^;|&]*-[[:alpha:]]*c(sbatch|qsub)"; then
  deny_msg "shell -c glued sbatch/qsub"
  exit 0
fi
if printf '%s' "$lower" | grep -Eiq "${seg}[[:space:]]*${wrap}eval[[:space:]]" \
  && printf '%s' "$lower" | grep -Eiq '(^|[^a-z])(sbatch|qsub)([^a-z]|$)'; then
  deny_msg "eval embedding sbatch/qsub"
  exit 0
fi

if printf '%s' "$norm" | grep -Eiq "${seg}[[:space:]]*${wrap}${bin}(sbatch|qsub)([[:space:]|&;]|$)"; then
  deny_msg "raw sbatch/qsub (command position)"
  exit 0
fi

if printf '%s' "$lower" | grep -Eiq "${seg}[[:space:]]*${wrap}${bin}(scp|rsync)[[:space:]]" \
  && printf '%s' "$lower" | grep -Eiq '(^|[[:space:]])([a-z0-9._-]+@)?(miyabi|pegasus|sirius|ppx)([-.a-z0-9]*)?:'; then
  deny_msg "scp/rsync to cluster"
  exit 0
fi

ssh_host_cluster="${seg}[[:space:]]*${wrap}${bin}ssh([[:space:]]+-[[:alnum:]]+([[:space:]]+[^-][^[:space:]]*)?)*[[:space:]]+([a-z0-9._-]+@)?(miyabi|pegasus|sirius|ppx)([-.a-z0-9]*)?([[:space:]]|$)"
if printf '%s' "$lower" | grep -Eiq "$ssh_host_cluster"; then
  deny_msg "ssh host is miyabi/pegasus/sirius/ppx"
  exit 0
fi

printf '%s\n' '{"permission":"allow"}'
exit 0
