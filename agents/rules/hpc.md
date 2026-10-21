# HPC 境界

## 1. 禁止コマンド

- 生の `sbatch` / `qsub`、および Miyabi / Pegasus / Sirius への `ssh` / `scp` / `rsync` は、Cursor hook `hpc-shell-gate` が deny する。
- 必ず `ppx_harness` / `miyabi_harness --dry-run` を経由する。実ログインは人間が行う。

## 2. ジョブ設計

- ジョブスクリプト作成、スケーリング実験計画、クラスタ投入準備の前に、必ずスキル `hpc-job-guardrails`（`~/dotfiles/agents/skills/hpc-job-guardrails/SKILL.md`）を読む。
- その規律（ノード分離・2ノード関門・ログインノード完結・Fail-Fast）を遵守する。
