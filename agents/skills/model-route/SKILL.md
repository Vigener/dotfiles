---
name: model-route
description: >-
  タスクに合うモデル・実行チャネル・effort と申請要否を、契約方針に沿って判定する。
  「どのモデルで回すべき？」「これOpus使うべき？」「should we use argon?」
  「carbon と argon」「hydrogen」「carbon-sub」「hydrogen-sub」「クォータ切れ」
  「モデルルーティング」「モデル判定」「model route」で使う。
---

# model-route

モデル選択の手順書。モデル名・割当・設定値はここに複製しない。

## 参照

回答前に `~/dotfiles/agents/rules/models.md`（契約・禁止・許可）と
`~/dotfiles/agents/docs/routing.md`（タスク対応）を読む。
既にこの作業で読んだ現行内容は再利用してよい。

## 判定

QEC・ftqc・b4 の研究担当と worker の分担許可は `models.md` §0.4 を参照。
本3タスクでは Grok の探索・案出し・比較検討・範囲を切った実装を許可する
（従来の用途制限へのタスク限定例外）。担当が全実装・探索を抱えず、
切り出せる実装は Terra / Sonnet、ツールが要る検索・抽出は Luna / Haiku /
許可タスクの Grok へ渡せる。Gemini の API は `carbon-sub` のみ。
ライブ提供確認・契約境界・総消費を守る。

**API の Gemini は Carbon のみ（2026-11-16）**: 正本 `models.md` §0.5 を優先する。
発想と暫定監査は `carbon-sub`。Argon を担当にしていた理由はサブスクの独立週枠で、
API にはその別枠がない。エージェントは `argon-sub` と `hydrogen-sub` を選ばない。
設計・仕様・W1 は Opus / Codex のまま。Carbon のサブスク掲載は待たない。

1. 依頼のモデル・effort・チャネル指定、Private、API・追加委譲禁止などの制約を
   確認する。名指しの無断変更はしない。
2. ローカル／Cursor Cloud、T3／CLI と、作業の種類・役割（設計・実装・抽出・
   探索・監査・Visual QA・推敲）を `routing.md` §1–§4 に照合する。
   Codex 内の作業別選択・孫委譲は `models.md` §2.5 を参照する。
   Gemini 4 系統は下記「API の Gemini は Carbon のみ」で決める。
3. Phase-First、ループ頭・末、前提崩れ・同指摘2回の引き上げを区別し、
   `models.md` §3.6–§3.7 で申請要否を判定する。格上げが要申請なら依頼前に
   1行で申請し、承認を待つ（Google API のみ §0.5 により理由1行記録で事後報告可）。
4. 選択が契約・プロバイダ固定・Private・従量API・Fast・Maker-Breaker の
   境界に合うか正本で確認する。残量ペースで動的に切り替えず、
   モデル名・slug・設定・残量を推測しない。

## 論文サーベイの振り分け

research-brain の `survey-papers` スキルは読解・整理の手順を担当し、モデル選択は
このスキルに集約する。検索・一次資料からの抽出・要約は Search / Extract、
研究課題の発想は Design（発想）、研究ゴール・評価仕様の策定は Design（ループ頭）
として正本に照合する。単なる調査依頼を研究方針の決定まで広げない。

## API の Gemini は Carbon のみ

事実の日付・出典は `models.md` §0.5・§1.1。ここは判定の手順。

1. **エージェントが Gemini を呼ぶとき**:
   - 呼ぶのは `carbon-sub`（既定 `medium`）だけ。担当は発想、暫定監査、
     渡されたテキストの要約・整形・推敲。設計・仕様・W1・ループ頭の引き上げは
     Opus / Codex のまま。Carbon へ付け替えない。
   - `argon-sub` と `hydrogen-sub` は選ばない。Argon の担当はサブスクの
     独立週枠があったときのもので、API ではその理由がない。
   - ツール・ファイル・Web 検索・PNG 目視は Gemini API にない。Codex /
     Claude / 許可タスクの Grok（非 Fast）を使う。
2. **チャネル境界（エージェントは Antigravity を起動しない）**:
   - エージェントは `delegate_task` の `providerInstanceId: "antigravity"` と
     `agy -p` / `agy acp` を使わない（`antigravity` 自身からの `delegate_task`
     も含む）。
   - `antigravity` は人間が T3 UI で直接開いたルートスレッド専用
     （同スレッド内の `invoke_subagent` は `Model: "inherit"` のみ）。
     掲載確認のために `orchestrator_capabilities` で `antigravity` を開かない。
     `cursor` に Gemini が出ていても選ばない。
3. **API の失敗**:
   - `~/.config/gemini-sub/.env` は Prepay / オートチャージ OFF が確認済み
     （`models.md` §0.5）。`carbon-sub` は都度確認なしで呼んでよい。
   - `429` / `RESOURCE_EXHAUSTED` / タイムアウトでは `agy`・`argon-sub`・
     `hydrogen-sub` へ逃がさない。プロンプトを圧縮して `carbon-sub` を
     再試行するか、停止して報告する。`--timeout 900` を維持する。
   - Carbon の `high` は無意味な引き上げを禁止し、必要なときだけ理由 1 行を
     記録して事後報告可（`models.md` §0.5）。

## 実行するときだけ読む

- 委譲手段・Fast の指定と確認: `~/dotfiles/agents/rules/delegation.md`。
  実行環境のツール契約も優先する。
- CLI ラッパーの引数・停止条件: `../codex-harness/SKILL.md`。`codex-sub` は
  API 自動切替を行わず停止する。DeepSeek が必要・許可済みなら許可を確認して
  別途 `dsh-sub`（`../deepseek-harness/SKILL.md`）を直接呼ぶ。
  Google API は `bin/carbon-sub` のみ（`models.md` §0.5）。
  `argon-sub` と `hydrogen-sub` は起動しない。
  API 禁止・モデル固定に反する切替は行わない。適合する経路がなければ
  停止して報告する。
- Typst: `../typst-workflow/SKILL.md`。分担・委譲制約は `models.md`「Typst」。
  HPC: `~/dotfiles/agents/rules/hpc.md` と該当するクラスタのスキル。

## 回答

推奨モデル・チャネル、effort・必要な設定、根拠の節、申請要否、次の行動を
短く示す。提案だけの依頼を実行許可に広げない。
記録が必要なら正本の記録規則に従う。
