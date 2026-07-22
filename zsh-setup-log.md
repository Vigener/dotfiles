# Zsh Setup Log

## 2026-07-15

### 現状確認
ユーザーから報告されたエラー：
```
/home/mikoto/.zshrc:source:38: no such file or directory: /home/mikoto/.oh-my-zsh/oh-my-zsh.sh
zsh: command not found: direnv
```

これにより、以下の項目が不足しているか正しく設定されていないことが疑われる：
1. `oh-my-zsh` がインストールされていない。
2. `zsh-autosuggestions`, `zsh-syntax-highlighting` などのzshプラグインがインストールされていない。
3. `direnv` がインストールされていない（またはパスが通っていない）。
4. `~/.zshrc` が `~/dotfiles/zsh/.zshrc` への正しいシンボリックリンクになっているか。

### 実施内容
1. **環境確認**:
   - `~/.zshrc` は正しく `dotfiles/zsh/.zshrc` へのシンボリックリンクになっていることを確認。
   - `~/.oh-my-zsh` が存在しないことを確認。
   - `direnv` がインストールされていないことを確認。
2. **Oh My Zsh およびプラグインのインストール**:
   - `git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh` を実行して Oh My Zsh をインストール。
   - `git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions` を実行。
   - `git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting` を実行。
3. **direnv のインストールと有効化**:
   - `mise install direnv` を実行して `direnv` をインストール。
   - `mise use -g direnv` を実行してグローバルに有効化。
4. **動作検証**:
   - `zsh -i -c "echo 'Test'"` を実行し、エラーなく `Test` が出力されることを確認。

### 結果
Zshの起動時のエラー（`oh-my-zsh.sh` が存在しないエラー、`direnv` コマンドが見つからないエラー）がすべて解消されました。
