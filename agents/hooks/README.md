# Cursor / Agent hooks（正本ミラー）

実行中: `~/.cursor/hooks.json` と `~/.cursor/hooks/*.sh`  
このディレクトリはミラー＋説明。**変更後は必ず `cp` で `~/.cursor/hooks/` に同期**（現状は symlink にしていない）。

## 導入

```bash
mkdir -p ~/.cursor/hooks
cp ~/dotfiles/agents/hooks/hpc-shell-gate.sh ~/dotfiles/agents/hooks/on-stop-open-artifact.sh ~/.cursor/hooks/
chmod +x ~/.cursor/hooks/*.sh
cp ~/dotfiles/agents/hooks/cursor-hooks.json.example ~/.cursor/hooks.json
# herdr の sessionStart パスを環境に合わせて編集
```

## フック

| イベント | スクリプト | 役割 |
|---|---|---|
| sessionStart | `herdr-agent-state.sh` | herdr |
| beforeShellExecution | `hpc-shell-gate.sh` | 生 scheduler / クラスタ ssh を deny |
| stop | `on-stop-open-artifact.sh` | `~/.cursor/open-on-stop.url` があるときだけ MBA open |

## hpc-shell-gate 回帰（手で回す）

```bash
G=~/.cursor/hooks/hpc-shell-gate.sh
check() { jq -n --arg c "$1" '{command:$c}' | bash "$G" | jq -r .permission; }
check 'sbatch x'                    # deny
check 'echo sbatch'                 # allow
check 'git commit -m "sbatch docs"' # allow
check 'bash -c "sbatch x"'          # deny
check 'python -m miyabi_harness a; sbatch x' # deny
check 'ssh ppx'                     # deny
check 'rsync -av ./a/ ./b-sirius/'  # allow（ローカル）
check 'rsync -av ./a/ miyabi:~/a/'  # deny
```

create-hook スキルで追加変更する。shell gate のみ `failClosed: true`。
