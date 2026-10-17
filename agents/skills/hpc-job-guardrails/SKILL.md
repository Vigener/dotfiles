---
name: hpc-job-guardrails
description: HPC/スパコン（Miyabi, PPX, Pegasus, Sirius等）におけるジョブスクリプト作成、スケーリング実験計画、メタスクリプト生成時に必ず参照する安全・コスト防衛ガイドライン。
---

# HPC 実験・ジョブ運用の安全・コスト防衛ガイドライン (hpc-job-guardrails)

本スキルは、スーパーコンピュータ（Miyabi, Pegasus, Sirius等）や専有クラスタ（PPX等）において、**計算資源・課金トークンの浪費を防ぎ、AIエージェントによる事故やアカウント凍結を防止しつつ、再現性の高い実験を遂行するための現場規律**をまとめたものである。

ジョブスクリプトの作成、スケーリング実験の計画、ジョブ自動生成スクリプトの作成、クラスタ投入準備を行う際は、**必ず事前に本ガイドラインを熟読し、すべての原則を遵守すること**。

---

## 1. コスト・計算資源防衛の3大鉄則 (Resource & Token Guardrails)

### ① スケーリング実験の「ノード分離」 (Per-Node Job Separation)
- **絶対禁止（異ノード同居の禁止）**:
  - **要求ノード数（`select=N` や `-N`）が異なる複数の実験を「1つのジョブスクリプト内にまとめて直列実行する」ことを固く禁じる**。
  - *理由*: 1つのジョブで最大ノード（例: 16ノード）を確保して内部で 1, 2, 4, 8, 16 ノードの直列ループを回すと、最も時間のかかる「1ノードの実行中」も残り15ノードが完全アイドル状態で課金され続け、トークンが猛烈な勢いで蒸発する。さらに大規模ノード確保はキュー待ち時間（Queue Wait）が極めて長くなる。
- **推奨規律**:
  - 必ず **ノード数ごとに独立したジョブスクリプト**（`job_n1.sh`, `job_n2.sh`, `job_n4.sh`...）を作成して個別にキューへ投入する。
  - スクリプトを手書きで量産すると記述ミスの原因になるため、パラメータを与えてノード別スクリプトを自動出力する **「メタ生成スクリプト（ジェネレータ）」** を作成・活用すること。
- **許容される同一ジョブ内ループ（境界条件）**:
  - **同一ノード数（特に1ノード内）** でスレッド数（OpenMP）・バッチサイズ・問題サイズ・パラメータ等をスイープする場合、各実行が短時間であり、かつ後述の Fail-Fast / タイムアウト防護が入っている限り、キュー待ち削減のために1つのジョブ内で直列ループ実行してよい。

### ② 環境構築・ビルドはログインノード完結 (Compute Node Isolation)
- **絶対禁止**: `pip install`、仮想環境（venv）の作成、ツールのダウンロード、`make` / `cmake` などの作業を**計算ノード（ジョブスクリプト内）で実行させてはならない**。
  - *理由*:
    1. 計算ノードはセキュリティ上、外部インターネット（PyPIやGitHub等）へのアクセスが遮断・制限されていることが多く、タイムアウトでハングして死ぬ。
    2. 高価なGPU・CPU計算資源をアイドリングさせたままパッケージインストールを待つのは、トークンと時間の重大な浪費である。
- **推奨規律と実務上の落とし穴防止**:
  - パッケージ導入やビルドは、**ログインノード上**で共有ファイルシステム（例: `/work/...` 配下）の venv やディレクトリに対して事前に済ませておく。
  - **`/home` 容量パンク防止**: venv 作成先やキャッシュ（`PIP_CACHE_DIR`）をデフォルトの `~/.cache` や `~/.venv`（`/home` 領域）に置かず、必ず `/work` 領域に指定する。
  - **ログインノード負荷制限**: ログインノードでビルドを行う際は、`make -j`（無制限）を避け、`make -j 4` 等に制限して他ユーザーへの迷惑・強制キルを防ぐ。
  - **クロスビルド注意**: ログインノードと計算ノードでCPUアーキテクチャが異なる場合や、GPUアーキテクチャ指定（`TORCH_CUDA_ARCH_LIST` や `-gpu=cc90`）が必要な場合は、ターゲット環境を明示してコンパイルする。

### ③ 即時異常終了 (Fail-Fast) とハング防護
- **絶対禁止**: エラーや通信デッドロックが発生しているにもかかわらずスクリプトが止まらず、**Walltimeの上限（強制キル）に達するまで計算ノードを無駄に占有し続ける実装**を禁じる。
- **推奨規律**:
  - **シェル側の基本**: スクリプト先頭には必ず `set -euo pipefail` を明記する。
  - **MPI/NCCL 通信ハングの防護（最重要）**:
    - マルチノード計算ではエラー終了よりも「通信デッドロック（ハング）」によるトークン蒸発が圧倒的に多い。`set -euo pipefail` だけではハングを止められないため、実行コマンドには必ず **GNU `timeout` コマンド**（Walltimeの約80%で SIGTERM、猶予後に SIGKILL）を併用する。
    - Python + MPI を使用する場合は `python3 -m mpi4py.run ...` を用いるか、例外キャッチ時に `MPI_Abort` を明示的に呼んで全ランクを道連れ終了させる。
    - PyTorch 分散学習（NCCL）を使用する場合は `export NCCL_ASYNC_ERROR_HANDLING=1` を設定し、ハートビートタイムアウトで即時終了させる。
  - **長時間スイープの自己防護**: スイープ処理には「残り時間が少なくなったら新規ループを開始せず安全に中断してサマリを出力する」ような内部タイマー制御を組み込む。

---

## 2. 投入フローの規律：ミニマム・ファースト (Progressive Scale-up)

いきなり全ノード・全スイープのジョブを一括投入してはならない。必ず以下の3段階のゲートを通過すること。

```
[Step 1: 1ノード極小 (Smoke)]
  └─ 最小構成・最小ステップでコードパス・引数・ファイル出力の正常通過を確認
       │ (成功: ログ内に exp_smoke_1_ok=1)
[Step 2: 2ノード通信関門 (Minimum Distributed Gate)]
  └─ 分散並列（MPI/NCCL通信、ノード間初期化）が動く最小単位で1本だけ確認
       │ (成功: ログ内に exp_gate_2_ok=1)
[Step 3: スケーリング本番展開 (Full Sweep)]
  └─ 本番問題サイズで N=1, 2, 4, 8, 16... を一括投入（基準点 N=1, 2 を欠落させない）
```

1. **Step 1: 1ノード極小 (Smoke)**
   - 本番と全く同一のコード経路で、問題サイズやステップ数を極小にしたスモークテスト（1ノード・数分以内）を実行し、引数や出力先パスが正しいことを確認する。
2. **Step 2: 2ノード通信関門 (Minimum Distributed Gate)**
   - マルチノード（スケーリング）実験を行う場合、いきなり8ノードや16ノードを投げず、**「2ノード（ノード間通信が発生する最小構成）」** を1本だけ投入する。
   - ノード間通信のハング、ホスト鍵問題、環境変数の不伝播、GPU-Aware MPI の非互換などはすべて2ノードの時点で炙り出せる。
3. **Step 3: スケーリング本番展開 (Full Sweep)**
   - 2ノードでの完走を確認した後に初めて、スケーリングジョブの投入へ進む。
   - **注意（基準点の欠落防止）**: Step 1/2 が極小問題サイズの場合、本番問題サイズのスケーリング比較には「本番サイズでの N=1（単体基準点）」および「N=2」の計測が必須である。Step 3 で `4, 8, 16` のみ投入して N=1, 2 の基準データを欠落させないこと。

---

## 3. 安全性と再現性の規律 (Safety & Provenance)

1. **AIと実機実行の物理的分離 (Privilege Separation)**:
   - **外部共用スパコン（Miyabi, Pegasus, Sirius等）**:
     - 生 `qsub` や自律的な SSH/rsync は厳禁。AIエージェントは「ジョブスクリプト生成」「メタ生成器の作成」「入力検証（dry-run）」「ログ解析」に徹する。
     - 実機への接続・同期・投入は、必ず**人間がOTP（ワンタイムパスワード）を用いて手動実行**する。
   - **専有クラスタ（PPX等）**:
     - 専有環境であっても生 `sbatch` の直叩きは避け、必ず決められたテストハーネス（`ppx_harness`）の安全機構を経由すること。
2. **明示的な成否フラグと偽陽性（False Positive）防止**:
   - ログ末尾にはジョブIDやタイムスタンプを含めた明示フラグ（例: `exp_node_{nodes}_job_${PBS_JOBID}_ok=1`）を出力させる。
   - 前段ゲート判定時や結果解析時は、**「直近のジョブIDに対応するログファイルのみ」** を対象とし、過去の実行ログの残存による誤判定を物理的に防ぐ。
3. **`/home` 出力の絶対禁止ガード**:

5. **コードと実験結果の一方向同期分離 (One-Way Sync Isolation)**:
   - **成果物除外の鉄則**: ローカルから計算機へ rsync するスクリプト（`sync_to_*.sh`）では、必ず `results/`, `logs/`, `*.svg`, `*.png`, `*.pdf`, `*.log` を厳格に `--exclude` すること。
   - **データ上書き破壊の防止**: 成果物ディレクトリを双方向に同期すると、クラスタ側で生成された最新の実行データがローカルの古いデータで不可逆的に上書き破壊される致命的リスクがある。計算機へは「ソースコードのみ」を送り、実験結果は「計算機からローカルへ回収（pull）するのみ」の一方向流を徹底する。
   - Miyabi/Pegasus/Sirius 等では `/home` への大容量出力や高頻度IOはクォータ制限超過・アカウント停止の主因となる。
   - ジョブスクリプト先頭で作業ディレクトリが `/home` 配下でないかを必ずアサートする。

4. **ジョブスケジューラ引数と環境変数注入の落とし穴 (Scheduler Pitfalls)**:
   - **PBS Pro `-v` のカンマ制限**: PBS Pro の `qsub -v` はカンマ（`,`）を環境変数の区切り文字として厳密にパースするため、値にカンマを含む（例: `-v SWEEP=1,2,4`）と不正な変数名として弾かれる（`cannot send environment with the job`）。リストや複数値を注入する場合は **コロン区切り（`:`）** を採用し、スクリプト側で `tr ':' ','` 等で正規化すること。
   - **スクリプト引数渡し**: PBS スクリプト実行時に動的引数を渡す際は `qsub script.sh -- --arg1 val1`（PBS Pro）やスクリプト内での `$@` 透過を設計しておく。

---

## 4. 実装テンプレート集

### A. ノード別メタ生成スクリプト例 (`generate_scaling_jobs.py`)
※ 以下は Miyabi-G (PBS Pro / GH200) 向けの例。Pegasus (NQSV) や PPX (Slurm) の場合は各クラスタのディレクティブ（`#PBS -A`, `#PBS -l elapstim_req=` や `#SBATCH`）に置き換えること。

```python
#!/usr/bin/env python3
"""スケーリング実験用ジョブスクリプトをノード数ごとに安全に生成するメタスクリプト。"""
import os
from pathlib import Path

# 実験対象のノード数リスト（本番スケーリング用）
NODES_LIST = [1, 2, 4, 8, 16]
WALLTIME_MAP = {
    1: ("00:05:00", 240),   # (walltime, timeout_sec: 約80%)
    2: ("00:05:00", 240),
    4: ("00:10:00", 480),
    8: ("00:15:00", 720),
    16: ("00:20:00", 960),
}
QUEUE = "debug-g"
GROUP = os.environ.get("HPC_GROUP", "xg26i048")
USER_ID = os.environ.get("HPC_USER", "x10752")

OUT_DIR = Path("generated_jobs")
OUT_DIR.mkdir(exist_ok=True)

TEMPLATE = """#!/bin/bash
#PBS -N exp_node_{nodes}
#PBS -q {queue}
#PBS -l select={nodes}
#PBS -l walltime={walltime}
#PBS -W group_list={group}
#PBS -j oe

set -euo pipefail
cd "${{PBS_O_WORKDIR}}"

# 1. /home 実行防止ガード
if [[ "${{PWD}}" == /home/* ]]; then
  echo "FATAL: Running jobs from /home is strictly prohibited. Use /work." >&2
  exit 1
fi

echo "Job started on $(hostname) at $(date)"
echo "Job ID: ${{PBS_JOBID:-N/A}}"
echo "Nodes allocated: {nodes}"

# 2. 共有ディスク上の構築済み venv をロード
source /work/{group}/{user}/venv/bin/activate

# 3. 実行（【最重要】必ず MPI ランチャー経由で全ノードを駆動し、timeout でハング自決を防ぐ）
# ※ 素の python3 run.py を叩くと 1 ノードしか動かず残り N-1 ノードがアイドル課金蒸発する！
timeout --kill-after=30s {timeout_sec}s \
  mpirun -np {nodes} --map-by ppr:1:node --bind-to none \
  python3 -m mpi4py.run run_experiment.py --nodes {nodes}

# 4. 明示的成功フラグの出力（ジョブIDを付与して過去ログ誤判定を防止）
echo "exp_node_{nodes}_job_${{PBS_JOBID:-local}}_ok=1"
echo "Job finished at $(date)"
"""

for nodes in NODES_LIST:
    walltime, timeout_sec = WALLTIME_MAP[nodes]
    script_content = TEMPLATE.format(
        nodes=nodes,
        queue=QUEUE,
        walltime=walltime,
        timeout_sec=timeout_sec,
        group=GROUP,
        user=USER_ID,
    )
    script_path = OUT_DIR / f"job_node_{nodes}.sh"
    script_path.write_text(script_content, encoding="utf-8", newline="\n")
    script_path.chmod(0o755)
    print(f"Generated: {script_path}")
```

### B. 人間用段階的投入スクリプト例 (`submit_scaling_step.sh`)
※ 本スクリプトは**人間が手動で段階実行するための案内ラッパー**である。AIエージェントによる直接実行は固く禁じる。

```bash
#!/usr/bin/env bash
# HUMAN-ONLY: AI agents must NEVER execute this script directly.
# スケーリング実験の段階的投入ラッパー（前段ゲート検査付き）
set -euo pipefail

STEP="${1:-help}"
LOG_DIR="${LOG_DIR:-logs}"
mkdir -p "${LOG_DIR}"

case "$STEP" in
  smoke)
    echo "=== [Step 1] Submitting 1-node smoke job ==="
    qsub generated_jobs/job_smoke_n1.sh
    echo "Wait for completion and verify logs before running 'gate2'."
    ;;

  gate2)
    echo "=== [Step 2] Checking Step 1 status and submitting 2-node gate ==="
    # 直近ログの成否検査（Step 1 未完了での突入を阻止）
    if ! grep -rq "exp_smoke_1.*_ok=1" "${LOG_DIR}/"; then
      echo "ERROR: Step 1 (smoke) has not succeeded yet (ok flag not found in ${LOG_DIR}/)." >&2
      exit 1
    fi
    echo "Step 1 OK. Submitting 2-node communication check..."
    qsub generated_jobs/job_gate_n2.sh
    echo "Wait for completion and verify logs before running 'scale'."
    ;;

  scale)
    echo "=== [Step 3] Checking Step 2 status and submitting full sweep ==="
    if ! grep -rq "exp_gate_2.*_ok=1" "${LOG_DIR}/"; then
      echo "ERROR: Step 2 (2-node gate) has not succeeded yet. Aborting scale submission." >&2
      exit 1
    fi
    echo "Step 2 OK. Submitting full scaling sweep (N=1, 2, 4, 8, 16)..."
    for n in 1 2 4 8 16; do
      qsub "generated_jobs/job_node_${n}.sh"
    done
    ;;

  *)
    echo "Usage: bash submit_scaling_step.sh [smoke | gate2 | scale]"
    exit 1
    ;;
esac
```
