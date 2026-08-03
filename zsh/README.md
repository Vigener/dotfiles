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

## ロールアウト（2026-08-03）

- **優先**: Mac mini（今後の母艦・見る時間が最長）で Starship を試す
- **MBA**: 現状の OMZ UI に満足なら **当面そのまま**。mini の見た目が良ければ後から移行
- **ThinkPad**: 共有 `zsh/.zshrc` 更新の都合で先行して Starship + ghq プラグイン導入済み
- mini がしっくりきたら MBA / ThinkPad（残作業・OMZ 削除など）へ横展開 → TODO: [now/TODO.md](file:///home/mikoto/brain/research-brain/now/TODO.md) の Mac mini 節「Starship の横展開」

注意: MBA で `~/dotfiles` を `git pull` すると `.zshrc` が Starship 前提になる。横展開前に pull するなら、その前に `brew install starship` と ghq の2プラグインが必要。

## symlink

`~/dotfiles/bin/link-dotfiles-macos.sh` が `~/.zshrc` をリンクする。実行前にパス一覧を確認すること。
