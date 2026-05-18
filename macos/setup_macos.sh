#!/bin/bash
# ~/dotfiles/setup_macos.sh

echo "macOSのシステム設定を適用します..."

# 例: PowerPointに「数式」のショートカット (^⇧-) を割り当てる（ダブルクォートは$を特殊文字として認識してしまうのでシングルクォート）
# @=Command, ~=Option, ^=Control, $=Shift
defaults write com.microsoft.Powerpoint NSUserKeyEquivalents -dict-add "数式" '^$-'

# 例: キーのリピート速度を最速にする（エンジニア必須設定）
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# 例: 隠しファイルを表示する
defaults write com.apple.finder AppleShowAllFiles -bool true

# 変更を反映するためにFinderやSystemUIServerを再起動
killall Finder
killall SystemUIServer

echo "設定が完了しました。"
