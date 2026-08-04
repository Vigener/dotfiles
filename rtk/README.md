# RTK（Rust Token Killer）

エージェント向けシェル出力の圧縮。別名「Rust Type Kit」と衝突するので、導入後は必ず `rtk gain` で確認する。

## 共有するもの

| もの | 扱い |
|---|---|
| `config.toml` | **このディレクトリが正本** → OS 別パスへ symlink |
| `filters.toml` | 当面なし（trust が機種ごと） |
| tee / history DB | 機種ローカル（git に載せない） |
| Cursor / pi の hook | 各機で `rtk init`（生成物） |

### config パス

| OS | リンク先 |
|---|---|
| Linux（TB） | `~/.config/rtk/config.toml` |
| macOS（MBA / mini） | `~/Library/Application Support/rtk/config.toml` |

```bash
# Linux
mkdir -p ~/.config/rtk
ln -sfn ~/dotfiles/rtk/config.toml ~/.config/rtk/config.toml

# macOS（または ~/dotfiles/bin/link-dotfiles-macos.sh）
mkdir -p "$HOME/Library/Application Support/rtk"
ln -sfn ~/dotfiles/rtk/config.toml "$HOME/Library/Application Support/rtk/config.toml"
```

## バイナリ

```bash
# macOS
brew install rtk   # または brew install rtk-ai/tap/rtk

# Linux
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
# → 通常 ~/.local/bin/rtk
```

検証: `rtk --version` / `rtk gain` / `which rtk`  
`gain` が無い → 別物。`cargo uninstall rtk` してから入れ直す。

## エージェント連携

Claude Code は触らない（`rtk init -g` 既定は Claude 向けなので注意）。

```bash
rtk init -g --agent pi
# Cursor: 既存 hooks をバックアップしてから。init が Claude も触る場合あり
cp ~/.cursor/hooks.json ~/.cursor/hooks.json.bak.$(date +%Y%m%d)
# 安全策: agents/hooks/cursor-hooks.json.example の preToolUse を手マージ
# または: rtk init -g --agent cursor --auto-patch 後に Claude 成果物を削除し、
#         Cursor の preToolUse が消えていたら example から戻す
```

確認: `hpc-shell-gate` / `sessionStart` / `stop` / `preToolUse`（`rtk hook cursor`）が共存していること。

一時無効: `RTK_DISABLED=1 git status`  
テレメトリ強制オフ: `RTK_TELEMETRY_DISABLED=1`
