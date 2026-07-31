# Cursor / Agent hooks（正本ミラー）

実行中の Cursor 設定は `~/.cursor/hooks.json` と `~/.cursor/hooks/*.sh`。  
このディレクトリはその **ミラー＋説明**（dotfiles で版管理）。

## 導入（新マシン）

```bash
mkdir -p ~/.cursor/hooks
cp ~/dotfiles/agents/hooks/hpc-shell-gate.sh ~/dotfiles/agents/hooks/on-stop-open-artifact.sh ~/.cursor/hooks/
chmod +x ~/.cursor/hooks/*.sh
cp ~/dotfiles/agents/hooks/cursor-hooks.json.example ~/.cursor/hooks.json
# herdr sessionStart パスが環境と違う場合は hooks.json を編集
```

## フック一覧

| イベント | スクリプト | 役割 |
|---|---|---|
| sessionStart | `~/.cursor/herdr-agent-state.sh`（既存） | herdr 状態 |
| beforeShellExecution | `hpc-shell-gate.sh` | 生 sbatch/qsub・Miyabi 系 ssh を deny |
| stop | `on-stop-open-artifact.sh` | `~/.cursor/open-on-stop.url` があるときだけ MBA で open |

`create-hook` スキル（Cursor 内蔵）で追加・変更する。failClosed は shell gate のみ。
