# 2026-09-17 Cursor Remote SSH from mini (`cursor .`)

## 結論

MBA で IDE（classic）を Remote SSH で開く正本コマンド:

```bash
/opt/homebrew/bin/cursor editor -n --classic --folder-uri "vscode-remote://ssh-remote+mini/Users/mikoto/ghq/github.com/Vigener/dotfiles"
```

Git Repos / `cursor --remote` 単体では Desktop/Agents に落ち、フォルダに入らない。

## 試行

- `cursor --remote ssh-remote+mini <path>` → Cursor Desktop が開くだけ。dotfiles に行かない
- `--remote` は cli.js にあるが help 非掲載。3.17 は最後にフォーカスした窓種別へ送る
- `~/.local/bin/cursor` は shim。確認は `/opt/homebrew/bin/cursor`（Cursor.app）
- 上記 `editor -n --classic --folder-uri vscode-remote://…` で希望どおり

## 実装

`zsh/mac/mac.zsh`: LocalHostName が `mikoto-mac-mini` のときだけ `cursor()` を定義し、`ssh mac` で上のコマンドを叩く。Cursor 統合端末（`VSCODE_IPC_HOOK_CLI`）と `agent` 等は素通し。
