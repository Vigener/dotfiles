# 🚀 Vigener's Dotfiles

開発環境設定ファイル群。
HPC/量子コンピュータ研究者として、「ノイズレス」「OS非依存（Mac/WSL共通）」「高パフォーマンス」をテーマに構築されたターミナル環境です。

## 思想 (Philosophy)

- **Universal:** macOS (Apple Silicon) と Linux (WSL) を自動判定し、1つのファイルで動作する。
- **Minimal:** 不要なコメントや使わないエイリアスを排除し、起動速度と可読性を最大化。
- **Infrastructure as Code:** 手作業を排除し、新端末でも数分で同じ環境を再現する。

## ディレクトリ構成と管理方針

このリポジトリは `ghq` によって管理され、実体は `~/ghq/github.com/.../dotfiles` に配置されます。
ホームディレクトリ（`~`）には、そこからのシンボリックリンク（ショートカット）を配置します。

### 管理対象ファイル

- `zsh/.zshrc`: Zsh のメイン設定ファイル。（`~/.zshrc` へリンク）
- `Brewfile`: Homebrew による Mac アプリ・CLI ツールの一括管理リスト。
- `karabiner/index.ts`: Karabiner-Elements のキーバインド設定。TypeScript ベースで管理され、ビルドにより `~/.config/karabiner/karabiner.json` に出力されます。（macOS のみ）
    - ⚠️ 自動生成される `karabiner.json` は Git 管理対象外です。編集は `index.ts` のみで行います。
- `herdr/.config/herdr/config.toml`: herdr（エージェント用ターミナルワークスペース）の共有設定。`~/.config/herdr/config.toml` へ symlink。
- `ghostty/.config/ghostty/config`: Ghostty（MBA・herdr 専用外側端末）の共有キーバインド。`~/.config/ghostty/config` へ symlink。`initial-command` は `~/.config/ghostty/config.local`（MBA のみ、symlink しない）。
- `rtk/config.toml`: RTK（トークン圧縮）の共有設定。Linux は `~/.config/rtk/`、macOS は `~/Library/Application Support/rtk/` へ symlink。
- `google-ime/azik_romantable.txt`: Google 日本語入力の AZIK ローマ字表。symlink しない。IME 設定からインポート。
- `autohotkey/main.ahk`: Windows 専用の AutoHotkey v2 キーバインド設定。Mac の Karabiner-Elements と同一の操作感を Windows 上に完全再現。（Windows のみ）

### リンク方針（Stow について）

パッケージ直下に `.config/` 等を置くレイアウトは GNU Stow 互換だが、**現行運用は選択的な `ln -s`（手作業）**。複数端末でログ・プラグイン絶対パス等が混在するため、`stow -t ~ <pkg>` による一括展開は推奨しない。`stow` 自体のインストールは任意。

## 🛠 新端末でのセットアップ手順 (Setup Guide)

### 1. リポジトリの取得 (ghq必須)

```bash
# ghqでリポジトリを取得
ghq get git@github.com:<Username>/dotfiles.git

# ホームディレクトリにdotfilesへのショートカットを作成（アクセス容易化）
ln -s $(ghq list -p exact_match_dotfiles_repo) ~/dotfiles
```

### 2. Zsh環境の構築

```bash
# 既存の .zshrc を退避
mv ~/.zshrc ~/.zshrc.bak

# シンボリックリンクの作成
ln -s ~/dotfiles/zsh/.zshrc ~/.zshrc

# Oh My Zsh 必須プラグインのインストール
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# 設定の反映
source ~/.zshrc
```

### 3. herdr（エージェントワークスペース）

エージェント制御プレーンとして **herdr** を使う。共有したい設定は `config.toml` のみ git 管理する。

#### 3.1 導入

```bash
# macOS
brew install herdr
# Linux: 公式のインストール手順に従う（例: curl インストーラ / ローカル bin）

mkdir -p ~/.config/herdr
# 既存の stub があれば退避してからリンク
# mv ~/.config/herdr/config.toml ~/.config/herdr/config.toml.stub.bak
ln -sfn ~/dotfiles/herdr/.config/herdr/config.toml ~/.config/herdr/config.toml

herdr   # または他マシンへ: herdr --remote <ssh-host>
herdr server reload-config   # 設定変更後
```

主な共有設定（`config.toml`）:

- Prefix: `ctrl+space`（配列で `prefix+key` と `prefix+ctrl+key` の dual-bind）
- 直叩き: `ctrl+alt+*` で pane hjkl・分割・zoom。タブ送りは `ctrl+tab` / `ctrl+shift+tab`
- Agents 切替: `comma` / `period`。`英数+1..9` → `ctrl+alt+1..9`
- Zoom 保険: `ctrl+shift+enter`（SSH 越しでも通りやすい）
- Agents パネル: pane（topic）優先表示（`[ui.sidebar.agents]`）
- CJK IME: `reveal_hidden_cursor_for_cjk_ime` / `cjk_ime_agents` / `switch_ascii_input_source_in_prefix`（**打鍵する Mac クライアント側**で効く。`--remote` 時も操作している Mac の config。変更後は **herdr クライアント再起動**）

同期しないもの（マシンローカル）: `*.sock` / ログ / `session.json` / `plugins.json` / `release-notes.json`（絶対パス・実行時生成）

リンク方針（MBA / mini / TB 共通）: **`~/.config/herdr` は実ディレクトリ**、`config.toml` だけを dotfiles へ symlink。ディレクトリ丸ごとリンクしない（機種ローカルが git 作業ツリーに混ざるため）。

母艦運用（MBA→mini）の正本は research-brain wiki: `wiki/compute-environments/mac-mini-mothership.md`（略称は `agents/glossary.md`）。

#### 3.2 プラグイン: pane-topic-sync

ペイン名をエージェントの topic（会話タイトル）に自動同期する。

```bash
# bun が PATH に入っていること（mise 等）
ghq get https://github.com/danbuhler/herdr-pane-topic-sync
herdr plugin link ~/ghq/github.com/danbuhler/herdr-pane-topic-sync
# 必要なら手動 sync
herdr plugin action invoke dan.pane-topic-sync.sync
```

注意:

- herdr サーバの PATH に `bun` が無い場合、プラグイン manifest の command を **bun の絶対パス**に直す必要がある（端末ごとにパスが違うため git に `plugins.json` は載せない）
- 推奨: `sync_panes = true` / `sync_tabs = false`（同タブ複数 pane でも agents パネルが同名にならない）
- 任意 config 例: `~/.config/herdr/plugins/config/dan.pane-topic-sync/config.toml`（dotfiles 側にミラー可）

### 3.3 RTK（トークン圧縮）

詳細: [`rtk/README.md`](rtk/README.md)。正本は `rtk/config.toml` のみ。

```bash
# macOS
brew install rtk
~/dotfiles/bin/link-dotfiles-macos.sh   # Application Support へリンク

# Linux
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
mkdir -p ~/.config/rtk
ln -sfn ~/dotfiles/rtk/config.toml ~/.config/rtk/config.toml

rtk gain   # 正しいパッケージか確認（無い＝別名 Rust Type Kit）
rtk init -g --agent pi
# Cursor: hooks.json をバックアップしてから
rtk init -g --agent cursor --auto-patch
```

### 3.4 Ghostty（MBA・herdr の外側端末）

Cmux の代わりに Ghostty を herdr 専用フロントにする。素のシェルは Warp。

```bash
~/dotfiles/bin/link-dotfiles-macos.sh
# MBA: ~/.config/ghostty/config.local が無ければ example から作成（initial-command）
# Ghostty を完全終了してから起動。herdr クライアントも再起動。
```

- 共有: `Cmd+T` → 新規タブ、`Cmd+W` → pane 閉じ、`Ctrl+Q` → デタッチ、`Ctrl+Tab` → タブ送り（いずれも prefix 列を `text:` で送る）。`Cmd+Q` はアプリ終了のまま。
- MBA ローカル: `initial-command = /opt/homebrew/bin/herdr --remote mini`（GUI は PATH が細い。2枚目は英数+N でシェル）
- 英数+Ctrl+HJKL/V/- は Karabiner の Ghostty 限定ルール

#### 3.4.1 Ghostty（ThinkPad Windows）

公式 Windows 版は未リリース。**LIL-JRG 非公式 Win32 ビルド**を使う。AutoHotkey の `APP_REGISTRY` は `%LocalAppData%\Programs\Ghostty\ghostty.exe` を想定。

前提: `winget install Git.Git`（日常シェルは Git Bash。PowerShell は winget 専用）

PowerShell（ThinkPad）:

```powershell
cd $HOME\ghq\github.com\Vigener\dotfiles
powershell -ExecutionPolicy Bypass -File .\bin\link-ghostty-windows.ps1 -Install
```

ホーム（`C:\Users\mikoto`）から `.\bin\...` は動かない。dotfiles の `bin` を指す。

- 配置: `%LOCALAPPDATA%\ghostty\config.ghostty`（共有）、`config.local.ghostty`（ThinkPad 専用・初回のみ example から作成）
- 1枚目: `initial-command = ssh mini`（Tailscale + `~/.ssh/config` の Host mini）
- 2枚目以降: `Ctrl+Shift+T` でローカル Git Bash
- macOS 版の `cmd+t` / herdr prefix キーバインドは **Windows では使わない**

### 4. 📱 macOS 固有のセットアップ

#### 4.1 Karabiner-Elements のセットアップ

Karabiner-Elements は macOS 専用のキーバインド設定ツールであり、TypeScript ベースの IaC (Infrastructure as Code) で完全管理されています。

**前提条件**：Homebrew と mise が必要です。

```bash
# Karabiner-Elements 本体と mise のインストール
brew install --cask karabiner-elements
brew install mise  # 未導入の場合
```

**環境構築**：

```bash
# karabiner ディレクトリへ移動
cd ~/dotfiles/karabiner

# mise を使って、このディレクトリ専用の Node.js (LTS版) を導入
mise use node@lts

# 依存パッケージのローカルインストール
npm install
```

**設定の反映**：

```bash
# 推奨: どのディレクトリからでも Karabiner 設定を再生成
mise run reload-karabiner

# （従来どおり karabiner 配下で直接実行する場合）
cd ~/dotfiles/karabiner && npm run build
```

実行した瞬間に `~/.config/karabiner/karabiner.json` が自動更新され、Karabiner-Elements のデーモンが自動的に再読み込みします。

**⚠️ 重要なルール**：

- **GUI操作は禁止**：Karabiner-Elements アプリ上で「Add predefined rule」などによるルール追加は、次回ビルド時にすべて上書きされます。
- **設定変更は `index.ts` のみ**：自動生成される `karabiner.json` は出力結果に過ぎず、直接編集は厳禁です。
- **`tsx` 採用理由**：ESM (ECMAScript Modules) 対応が必要なため、`tsx` を採用しています。

#### 4.2 Windows 固有のセットアップ (AutoHotkey v2)

Windows 端末で macOS (Karabiner-Elements) と同一のキーバインドを再現するための設定です。

詳細は [`autohotkey/README.md`](autohotkey/README.md) を参照してください。

```powershell
# 1. AutoHotkey v2 のインストール
winget install AutoHotkey.AutoHotkey

# 2. スタートアップ登録（PC起動時に自動常駐）
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\AutoHotkey_dotfiles.lnk")
$Shortcut.TargetPath = "$HOME\dotfiles\autohotkey\main.ahk"
$Shortcut.WorkingDirectory = "$HOME\dotfiles\autohotkey"
$Shortcut.Save()
```

### 5. Gitのグローバル設定（ノイズ排除）

Mac特有のゴミファイル（`.DS_Store` 等）がGitに混入するのを防ぐため、グローバルな `.gitignore` を適用します。

```bash
# シンボリックリンクの作成
ln -s ~/dotfiles/.gitignore_global ~/.gitignore_global

# Git全体に適用
git config --global core.excludesfile ~/.gitignore_global
```

## ⚠️ 運用上の注意点 (Caveats)

### 共通事項

1. **シンボリックリンクの破壊に注意**
    - `code ~/.zshrc` や `echo "..." >> ~/.zshrc` による編集・追記は安全（リンク先のターゲットが編集される）。
    - `cp new_file ~/.zshrc` や、一部のコマンド（`sed -i` など）は、リンクの「土管」自体を破壊し、ただの独立したファイルに置き換わってしまうため**厳禁**。
    - **ベストプラクティス:** 設定を変更する際は、`cd ~/dotfiles` で実体のディレクトリに移動し、そこから編集・Gitコミットを行うこと。

2. **環境依存のシークレット情報について**
    - APIキーや、そのPCでしか使わない特殊な設定（ノイズ）は、この `zshrc` には書かないこと。
    - 代わりに `~/.zshrc.local` というファイルを作成し、そこに記述する。（`zshrc` が自動で読み込む設計になっているため、GitHubにシークレットが漏洩するのを防げる）

### macOS 固有: Karabiner-Elements の運用ルール

1. **GUI操作の禁止**
    - Karabiner-Elements アプリ上の `Complex Modifications` タブから「Add predefined rule」等を使用してルールを追加しないでください。
    - 次回の `npm run build` 実行時にすべて上書き（削除）されます。

2. **生成された `karabiner.json` は触らない、Git に入れない**
    - 自動生成される `karabiner.json` はビルドの「出力結果」に過ぎません。
    - 直接編集は厳禁であり、ノイズになるため dotfiles の Git 管理からも除外しています（`.gitignore` 記載済み）。

3. **設定変更方法**
    - **すべての変更は `index.ts` で行う**。編集・追記後に `mise run reload-karabiner`（または `cd ~/dotfiles/karabiner && npm run build`）を実行するだけです。
    - ルール追加時は `assets/complex_modifications` のリンク状態も確認してください（ユーザーメモリ参照）。

4. **実行環境に `tsx` を採用している理由**
    - `karabiner.ts` は ESM (ECMAScript Modules) を使用しており、従来の `ts-node` では `require is not defined` などの致命的エラーが発生します。
    - `tsx` は設定不要で ESM/CJS の混在をよしなに解決するため、本環境で採用しています。
