---
name: update-agent-config
description: >-
  AI エージェントのルール・スキル・ハーネス・ルーティングなど「挙動設定」を更新するときの手順。
  「ルール追加」「スキル作成」「AGENTS.md いじり」「モデルルーティング更新」「ハーネス方針変更」等で発動。
  Context→Harness→Loop→Graph の層を判定し、壊さない最小変更にする。
---

# update-agent-config

## 目的

エージェント挙動の変更を、Agent Engineering 系譜（Prompt ⊂ Context ⊂ 狭義 Harness / Loop / Graph A、Graph B は直交）に沿って**層を誤認せず**行う。

参照原本:

- `~/brain/research-brain/wiki/ai-engineering/loop-and-harness-engineering.html`
- `~/brain/research-brain/wiki/ai-engineering/cursor_model_routing.md`
- `~/dotfiles/agents/GLOBAL_RULES.md`
- スキル正本: `~/dotfiles/agents/skills/`（`~/.cursor/skills` は symlink）

## ステップ 1: 層を判定する（必須）

| 層 | 触るものの例 | 触らない方がよいもの |
|----|--------------|----------------------|
| **Context** | `AGENTS.md` / Rules / SKILL 説明 / `AGENTS.md` 系の注入内容 | 実行グラフ全体の再設計 |
| **狭義 Harness** | ツール許可・権限・sandbox・`ppx_harness` 契約・hooks | プロンプト文言だけの微調整で済ませるべきこと |
| **Loop** | トリガー・Verifier・停止条件・cron/routines | 単発タスクへの過剰ループ導入 |
| **Graph A** | ノード分割・HumanGate・handoff・checkpoint | 単一 Loop で足りるフローへのフレームワーク導入 |
| **Graph B** | 知識グラフ / SPO メモリ（直交） | 実行トポロジと混同した「Graph」改名 |

**不要条件を先に書く:** 単発なら Loop 不要。単純遷移なら Graph A 不要。関係横断が不要なら Graph B 不要。

## ステップ 2: 変更場所（dotfiles 一元化）

| 対象 | パス |
|------|------|
| 個人スキル | `~/dotfiles/agents/skills/<name>/SKILL.md` |
| グローバル規則テキスト | `~/dotfiles/agents/GLOBAL_RULES.md` / `~/dotfiles/agents/rules/` |
| Cursor alwaysApply（brain ワークスペース） | `~/brain/.cursor/rules/*.mdc`（git 外の場合あり → wiki にも要旨を残す） |
| research-brain プロジェクト規則 | `~/brain/research-brain/.agents/AGENTS.md`（書き込み禁止ファイルに注意） |
| life-brain プロジェクト規則 | `~/ghq/github.com/Vigener/life-brain/.agents/AGENTS.md` / `.cursor/rules/` |
| life-brain リポスキル | `life-brain/.agents/skills/`（Cursor 用: `.cursor/skills/` から symlink） |
| モデル方針の説明 | `~/brain/research-brain/wiki/ai-engineering/cursor_model_routing.md` 等 |

スキル新規作成後は `~/.cursor/skills` が symlink なら追加操作不要。

## ステップ 3: モデルの使い分け（このスキル作業自体）

| 作業 | 推奨 |
|------|------|
| スキル草案・ルール短文・差分整理 | `agy --model gemini-3.6-flash-high` または `pi --model opencode-go/kimi-k3 --no-tools` |
| 破壊的・インフラ・Git 危険操作の監査 | Cursor Sonnet / agy `claude-sonnet-4-6` |
| 単純ファイル配置・symlink 確認 | 現行エージェントで十分 |

## ステップ 4: 検証

1. 変更ファイルを1つ以上人間が読める形で示す（HTML なら `open-artifact`）
2. 「どの層を触ったか」「不要条件」「ロールバック方法」を3行で報告
3. ユーザーが却下したら**元に戻す**（git checkout / バックアップ）

## ステップ 5: コミット

dotfiles 変更は `git-semantic-commit` スキルに従い、ユーザーがコミット依頼したとき（または明示依頼時）に push まで。

## 禁止

- 頼まれていない既存ルーティング表の全面書き換え
- Graph 語彙で Knowledge Graph と実行グラフを混同した説明の追加
- `CLAUDE.md` / `context/current_state.md` など書き込み禁止ファイルへの無断編集
