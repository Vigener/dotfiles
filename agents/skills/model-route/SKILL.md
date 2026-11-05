---
name: model-route
description: >-
  タスクに合うモデル・実行チャネル・effort と申請要否を、契約方針に沿って判定する。
  「どのモデルで回すべき？」「これOpus使うべき？」「should we use argon?」
  「モデルルーティング」「モデル判定」「model route」で使う。
---

# model-route

モデル選択の手順書。モデル名・割当・設定値はここに複製しない。

## 参照

回答前に `~/dotfiles/agents/rules/models.md`（契約・禁止・許可）と
`~/dotfiles/agents/docs/routing.md`（タスク対応）を読む。
既にこの作業で読んだ現行内容は再利用してよい。

## 判定

1. 依頼のモデル・effort・チャネル指定、Private、API・追加委譲禁止などの制約を
   確認する。名指しの無断変更はしない。
2. ローカル／Cursor Cloud、T3／CLI と、作業の種類・役割（設計・実装・抽出・
   探索・監査・Visual QA・推敲）を `routing.md` §1–§4 に照合する。
   Codex 内の作業別選択・孫委譲は `models.md` §2.5 を参照する。
3. Phase-First、ループ頭・末、前提崩れ・同指摘2回の引き上げを区別し、
   `models.md` §3.6–§3.7 で申請要否を判定する。格上げが要申請なら依頼前に
   1行で申請し、承認を待つ。
4. 選択が契約・プロバイダ固定・Private・従量API・Fast・Maker-Breaker の
   境界に合うか正本で確認する。残量ペースで動的に切り替えず、
   モデル名・slug・設定・残量を推測しない。

## 実行するときだけ読む

- 委譲手段・Fast の指定と確認: `~/dotfiles/agents/rules/delegation.md`。
  実行環境のツール契約も優先する。
- CLI ラッパーの引数・停止条件: `../codex-harness/SKILL.md`。`codex-sub` は
  API 自動切替を行わず停止する。DeepSeek が必要・許可済みなら許可を確認して
  別途 `dsh-sub`（`../deepseek-harness/SKILL.md`）を直接呼ぶ。
  API 禁止・モデル固定に反する切替は行わない。適合する経路がなければ
  停止して報告する。
- Typst: `../typst-workflow/SKILL.md`。分担・委譲制約は `models.md`「Typst」。
  HPC: `~/dotfiles/agents/rules/hpc.md` と該当するクラスタのスキル。

## 回答

推奨モデル・チャネル、effort・必要な設定、根拠の節、申請要否、次の行動を
短く示す。提案だけの依頼を実行許可に広げない。
記録が必要なら正本の記録規則に従う。
