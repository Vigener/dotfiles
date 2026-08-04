# zsh（dotfiles）

## 読み込み順

1. **`.zprofile`**（ログインシェル）— 機種ローカル可。dotfiles からはリンクしない（mini 方針）
2. **`.zshrc`** ← `~/dotfiles/zsh/.zshrc`
3. Darwin なら先頭で **`mac/mac.zsh`**、Linux なら **`thinkpad/thinkpad.zsh`**
4. 最後に **`~/.zshrc.local`**（秘密・機種専用）

## 見た目・プラグイン（2026-08 方針）

| 役割 | 手段 |
|---|---|
| プロンプト（現在地） | **Starship**（初回はデフォルト。`starship.toml` なし） |
| サジェスト | `zsh-autosuggestions`（ghq） |
| 色付け | `zsh-syntax-highlighting`（ghq） |
| 補完 | zsh 本体 `compinit` |
| Oh My Zsh | **使わない**（少数プラグインなら直接 source の方が単純） |

```bash
brew install starship   # Mac。Linux は公式 install または brew
ghq get https://github.com/zsh-users/zsh-autosuggestions
ghq get https://github.com/zsh-users/zsh-syntax-highlighting
```

更新は任意（現状で足りるなら `git pull` しなくてよい）。

## ロールアウト（2026-08-04 完了）

- **MBA / mini / TB**: Starship + ghq の2プラグイン導入済み。OMZ は使わない
- 新規機: `brew install starship`（Linux は公式 or brew）→ 上記 `ghq get` 2本 → `~/dotfiles` の `.zshrc` をリンク／source
- 運用正本（母艦）: [mac-mini-mothership.md](file:///home/mikoto/brain/research-brain/wiki/compute-environments/mac-mini-mothership.md)

## リポジトリパス（2026-08）

- **正本（実体）**: `~/ghq/github.com/<owner>/<repo>`（マシン横断で一意）
- **入口**: **zoxide** / `cdg`（ghq+fzf）。短い `~/brain`・`~/projects` symlink は **当面なし**
- GitHub 管理のリポはホーム上も同列（research-brain も projects の一つ）
- MBA / TB の歴史的パス差は許容。常用は ghq+zoxide へ寄せる（mini 母艦カットオーバー済み）

## symlink

`~/dotfiles/bin/link-dotfiles-macos.sh` が `~/.zshrc` をリンクする。実行前にパス一覧を確認すること。
