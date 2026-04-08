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

- `zshrc`: Zsh のメイン設定ファイル。(`~/.zshrc` へリンク)
- `Brewfile`: (予定) Homebrew による Mac アプリ・CLI ツールの一括管理リスト。
- `karabiner/index.ts`: Karabiner-Elements のキーバインド設定。TypeScript ベースで管理され、ビルドにより `~/.config/karabiner/karabiner.json` に出力されます。（macOS のみ）
    - ⚠️ 自動生成される `karabiner.json` は Git 管理対象外です。編集は `index.ts` のみで行います。

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
ln -s ~/dotfiles/zshrc ~/.zshrc

# Oh My Zsh 必須プラグインのインストール
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# 設定の反映
source ~/.zshrc
```

### 3. 📱 macOS 固有のセットアップ

#### 3.1 Karabiner-Elements のセットアップ

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
# index.ts をコンパイルし、設定ファイルを生成・適用
npm run build
```

実行した瞬間に `~/.config/karabiner/karabiner.json` が自動更新され、Karabiner-Elements のデーモンが自動的に再読み込みします。

**⚠️ 重要なルール**：

- **GUI操作は禁止**：Karabiner-Elements アプリ上で「Add predefined rule」などによるルール追加は、次回ビルド時にすべて上書きされます。
- **設定変更は `index.ts` のみ**：自動生成される `karabiner.json` は出力結果に過ぎず、直接編集は厳禁です。
- **`tsx` 採用理由**：ESM (ECMAScript Modules) 対応が必要なため、`tsx` を採用しています。

### 4. Gitのグローバル設定（ノイズ排除）

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
    - **すべての変更は `index.ts` で行う**。編集・追記後に `npm run build` を実行するだけです。
    - ルール追加時は `assets/complex_modifications` のリンク状態も確認してください（ユーザーメモリ参照）。

4. **実行環境に `tsx` を採用している理由**
    - `karabiner.ts` は ESM (ECMAScript Modules) を使用しており、従来の `ts-node` では `require is not defined` などの致命的エラーが発生します。
    - `tsx` は設定不要で ESM/CJS の混在をよしなに解決するため、本環境で採用しています。
