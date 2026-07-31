#!/usr/bin/env bash
set -euo pipefail
G="${1:-$HOME/.cursor/hooks/hpc-shell-gate.sh}"
fail=0
run() {
  local c="$1" exp="$2" r
  r=$(jq -n --arg c "$c" '{command:$c}' | bash "$G" | jq -r .permission)
  if [[ "$r" != "$exp" ]]; then echo "FAIL want=$exp got=$r | $c"; fail=1; else echo "OK $exp | $c"; fi
}
# deny
run 'sbatch job.sh' deny
run '"sbatch" job.sh' deny
run 's\batch job.sh' deny
run 'bash -lc "sbatch x"' deny
run '/bin/bash -c "sbatch x"' deny
run 'true && bash -c "sbatch x"' deny
run 'python -m miyabi_harness a; sbatch x' deny
run '/usr/bin/sbatch x' deny
run 'command sbatch x' deny
run 'FOO=bar sbatch x' deny
run '/usr/bin/env sbatch x' deny
run 'ssh ppx' deny
run 'ssh -o BatchMode=yes ppx' deny
run 'command ssh miyabi-g' deny
run 'scp file ppx:~/' deny
run 'rsync -av ./a/ miyabi:~/' deny
run 'find . -exec sbatch {} ;' deny
# allow
run 'echo sbatch' allow
run 'git commit -m "sbatch docs"' allow
run 'grep sbatch README.md' allow
run 'ssh mac' allow
run 'ssh -o BatchMode=yes -o ConnectTimeout=5 mac' allow
run 'ssh mac "echo miyabi docs"' allow
run 'ssh mac "open http://example/miyabi.html"' allow
run 'rsync -av ./a/ ./b-sirius/' allow
run 'uv run python -m miyabi_harness x --dry-run' allow
run 'ls' allow
exit "$fail"
