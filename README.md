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
- `zshrc`: Zshのメイン設定ファイル。(`~/.zshrc` へリンク)
- `Brewfile`: (予定) HomebrewによるMacアプリ・CLIツールの一括管理リスト。
- `karabiner.json`: (予定) Karabiner-Elementsのキーバインド設定。

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
git clone [https://github.com/zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone [https://github.com/zsh-users/zsh-syntax-highlighting.git](https://github.com/zsh-users/zsh-syntax-highlighting.git) ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# 設定の反映
source ~/.zshrc
```

## ⚠️ 運用上の注意点 (Caveats)

1. **シンボリックリンクの破壊に注意**
   - `code ~/.zshrc` や `echo "..." >> ~/.zshrc` による編集・追記は安全（リンク先のターゲットが編集される）。
   - `cp new_file ~/.zshrc` や、一部のコマンド（`sed -i` など）は、リンクの「土管」自体を破壊し、ただの独立したファイルに置き換わってしまうため**厳禁**。
   - **ベストプラクティス:** 設定を変更する際は、`cd ~/dotfiles` で実体のディレクトリに移動し、そこから編集・Gitコミットを行うこと。

2. **環境依存のシークレット情報について**
   - APIキーや、そのPCでしか使わない特殊な設定（ノイズ）は、この `zshrc` には書かないこと。
   - 代わりに `~/.zshrc.local` というファイルを作成し、そこに記述する。（`zshrc` が自動で読み込む設計になっているため、GitHubにシークレットが漏洩するのを防げる）
