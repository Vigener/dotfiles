#!/usr/bin/env bash
# Cursor beforeShellExecution: block raw HPC submit / cluster login bypass.
# Fail closed on parse errors. Allow harness module invocations.
set -u

input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.command // empty' 2>/dev/null || true)"

if [[ -z "${cmd}" ]]; then
  # No command field — fail closed
  printf '%s\n' '{"permission":"deny","user_message":"hpc-shell-gate: could not parse shell command; denied.","agent_message":"Shell hook parse failed; re-run via ppx_harness / miyabi_harness dry-run."}'
  exit 0
fi

# Explicit allow: harness CLIs (not raw sbatch)
if [[ "$cmd" =~ python[[:space:]]+-m[[:space:]]+miyabi_harness ]] \
  || [[ "$cmd" =~ python[[:space:]]+-m[[:space:]]+ppx_harness ]] \
  || [[ "$cmd" =~ uv[[:space:]]+run[[:space:]]+python[[:space:]]+-m[[:space:]]+miyabi_harness ]] \
  || [[ "$cmd" =~ uv[[:space:]]+run[[:space:]]+python[[:space:]]+-m[[:space:]]+ppx_harness ]] \
  || [[ "$cmd" =~ ppx_harness\.py ]]; then
  printf '%s\n' '{"permission":"allow"}'
  exit 0
fi

deny_msg() {
  local why="$1"
  jq -n --arg why "$why" \
    '{permission:"deny",
      user_message:("Blocked by hpc-shell-gate: "+$why),
      agent_message:("Use ppx_harness or miyabi_harness --dry-run. Raw cluster submit/login is HumanGate-only. Why: "+$why)}'
}

# Raw schedulers
if [[ "$cmd" =~ (^|[[:space:];|&])sbatch([[:space:]]|$) ]] \
  || [[ "$cmd" =~ (^|[[:space:];|&])qsub([[:space:]]|$) ]]; then
  deny_msg "raw sbatch/qsub" 
  exit 0
fi

# Cluster SSH / rsync targets (Miyabi / Pegasus / Sirius)
# Matches: ssh miyabi, ssh miyabi-g, ssh user@miyabi..., scp/rsync ... miyabi
lower="$(printf '%s' "$cmd" | tr '[:upper:]' '[:lower:]')"
if [[ "$lower" =~ (^|[[:space:];|&])ssh[[:space:]] ]] \
  || [[ "$lower" =~ (^|[[:space:];|&])scp[[:space:]] ]] \
  || [[ "$lower" =~ (^|[[:space:];|&])rsync[[:space:]] ]]; then
  if [[ "$lower" =~ miyabi ]] || [[ "$lower" =~ pegasus ]] || [[ "$lower" =~ sirius ]]; then
    deny_msg "ssh/scp/rsync to miyabi/pegasus/sirius"
    exit 0
  fi
fi

printf '%s\n' '{"permission":"allow"}'
exit 0
