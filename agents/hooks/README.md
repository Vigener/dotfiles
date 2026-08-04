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
| preToolUse | `rtk hook cursor` | Shell を RTK 経由に rewrite（バイナリ必須） |

### RTK（preToolUse）

- 正本の設定は [`rtk/README.md`](../../rtk/README.md)。`rtk` が PATH にあること。
- **推奨**: example をベースに手で `preToolUse` を足すか、既存 `hooks.json` に上記エントリをマージする。
- `rtk init -g --agent cursor` は Claude 向け hook も触ることがある。使わないなら Claude 成果物を入れない／入れたら手で外す。
- `rtk init -g --uninstall --agent claude` は **Cursor の RTK 条目も消す**ことがある → 消えたら example の `preToolUse` を戻す。
- 導入後は必ず `hpc-shell-gate` / `sessionStart` / `stop` が残っているか確認。

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
