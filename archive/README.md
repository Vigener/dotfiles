# archive/

常用していない設定・バックアップの退避場所。  
再導入時の参考用。ルートを薄く保つためにここへ移す。

| パス | 由来 |
|---|---|
| `aerospace/` | 窓管理 AeroSpace（アプリはアンインストール済） |
| `zellij/` | 旧マルチプレクサ設定（herdr へ移行） |
| `vibe-dictator/` | お試し設定サンプル |
| `ThinkPad_Settings/` | 旧 VS Code 等の ThinkPad 向け断片 |
| `NSGlobalDomain_backup.txt` / `Powerpoint_backup.txt` | macOS defaults 系ダンプ |
| `macos/backup_2026-05-08/` | 同上の日付付きバックアップ |
| `zsh-setup-log.md` | 2026-07-15 TB の OMZ/direnv 復旧ログ（現行は Starship 方針で古い） |

復元例: 必要なファイルだけ `archive/...` から取り出し、現行の配置規則（ファイル単位 symlink 等）に合わせる。
