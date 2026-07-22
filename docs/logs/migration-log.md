# dotfiles への Cursor ルール追加およびスキル管理の一元化・移行作業ログ

## 日時
- 2026-07-22

## 概要
Cursor / agy / 他コーディングエージェントのルール・スキル管理を `~/dotfiles` 配下に一元化・共通化するための移行作業を実施。

## 実施作業内容

### 1. Cursor 用共通ルールの作成 (`~/dotfiles`)
- `~/dotfiles/agents/rules/cursorrules` を新規作成。
  - 司令塔: Sonnet 5 (API) ➔ サブ Grok 4.5
  - 実装役: 1st Composer 2.5 (Standard) ➔ 2nd DeepSeek V4 Pro ➔ 3rd Gemini 3.6 Flash
  - ルートクリーン保持・ログ `docs/logs/` 隔離ルールを記載。

### 2. 各プロジェクトへのシンボリックリンク作成
- 対象プロジェクト（`hybrid-workflow-sandbox`、`dotfiles`ルート、ホームディレクトリ）に `.cursorrules` シンボリックリンクを設置。

### 3. スキルの一元管理移行
- `~/dotfiles/agents/skills/` 配下に `karabiner-elements-update` 等を統合し、全スキルの `SKILL.md` フォーマット遵守を確認。

### 4. pi-coding-agent の分離保持
- 軽量デバッグ用 `pi` (`~/.pi/agent/`) においてはルールやスキルの自動読み込み（自動インポート）を行わず、コンテキスト最小化のためのスパルタン設定を維持していることを確認。

### 5. Gemini スキルを Cursor でも利用可能に
- Gemini / agy は `~/.gemini/config/skills.json` で `~/dotfiles/agents/skills` を参照済み。
- Cursor 用に同ディレクトリへシンボリックリンクを追加:
  - `~/.cursor/skills` → `~/dotfiles/agents/skills`（全プロジェクトで個人スキルとして発見）
  - `~/dotfiles/.agents/skills` → `../agents/skills`（プロジェクト内の重複コピーを廃止し一元化）
- 公開スキル: `git-semantic-commit`, `hpc-coding-expert`, `karabiner-elements-update`, `miyabi-expert`, `pegasus-expert`, `ppx-expert`, `sirius-expert`

