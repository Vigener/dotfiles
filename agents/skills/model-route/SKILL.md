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

1. 依頼のモデル・effort・チャネル指定、Private、API・追加委譲禁止などの制約を
   確認する。名指しの無断変更はしない。
2. ローカル／Cursor Cloud、T3／CLI と、作業の種類・役割（設計・実装・抽出・
   探索・監査・Visual QA・推敲）を `routing.md` §1–§4 に照合する。
   Codex 内の作業別選択・孫委譲は `models.md` §2.5 を参照する。
   Gemini 4 系統は下記「Argon・Carbon・Hydrogen の使い分け」で決める。
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

## Argon・Carbon・Hydrogen の使い分け

事実の日付・出典・ベンチマーク境界は `models.md` §0.5・§1–§1.2。ここは判定の手順。

1. **公式ポジション（全領域で Hydrogen > Argon ではない）**:
   - **Hydrogen (`gemini-4-hydrogen`)**: 旧 `3.8 Flash` からの推奨移行先。
     Search・W2・Extract・整形・Visual QA・yomiyasu と並列実行向き。
     **`agy` は既定 `high` のため `thinking_level: medium`（軽作業 `low`）を必ず明示**する。
   - **Argon (`gemini-4-argon`)**: 低ハルシネーション（`AA-Omniscience`）・
     図表読解・科学ベンチでなお優位。`agy` では非繰越の独立週枠を発想と
     暫定監査（`models.md` §2.5）に集中させ、**有料 API では最小限に抑える**。
   - **Carbon (`gemini-4-carbon`)**: 限界を試す作業（複雑多段デバッグ・
     開かれた科学的探求）。設計・仕様・W1・ループ頭と引き上げは従来どおり
     Opus / Codex であり、Carbon へ付け替えない。
2. **Antigravity の Carbon ガード**:
   - **前提**: Carbon は Google AI Pro の Antigravity にも来る想定。
   - **呼ぶ直前**: `orchestrator_capabilities` で `antigravity` に Carbon が
     あるか見る。あるときだけサブスクで呼ぶ。無い間はサブスクで呼ばず報告する。
     `cursor` に出ていても選ばない。
3. **API（`gemini-sub` 系）とクォータ切れフォールバック**:
   - `~/.config/gemini-sub/.env` は Prepay / オートチャージ OFF が確認済み
     （`models.md` §0.5）。サブスク優先を維持しつつ、枠切れ時や API 適合タスクでは
     都度確認なしで呼んでよい。
   - **`agy` Argon 枠切れ時**: Argon の低ハルシネーション必須でなければ
     `agy` Hydrogen または Web 版 Argon を優先。Argon 自体が必要なら `argon-sub`。
   - **`agy` Gemini 枠切れ時**: `hydrogen-sub`。
   - **API 利用時の主軸**: `hydrogen-sub` または `carbon-sub`（限界を試す難所のみ）を
     優先し、`argon-sub` の乱発を避ける。Carbon は `--timeout 900`・圧縮プロンプトを
     維持し、タイムアウト時は圧縮再試行または `argon-sub` / `hydrogen-sub` へ退避する。
   - **effort**: 既定 `medium`（軽作業 `low`）。API でも無意味な `high` / `xhigh`
     引き上げは禁止。必要なときは **理由を 1 行記録して事後報告可**（`models.md` §0.5）。
4. **価格**: Argon と Carbon の導入期間は 2026-11-30 まで、標準単価は
   2026-12-01 から（スケジュール同一）。金額は写さず料金表を見る
   （`models.md` §0.5・§1.1）。Carbon はトークンが多いため、割引終了後も
   安い側として Carbon を優先しない。

## 実行するときだけ読む

- 委譲手段・Fast の指定と確認: `~/dotfiles/agents/rules/delegation.md`。
  実行環境のツール契約も優先する。
- CLI ラッパーの引数・停止条件: `../codex-harness/SKILL.md`。`codex-sub` は
  API 自動切替を行わず停止する。DeepSeek が必要・許可済みなら許可を確認して
  別途 `dsh-sub`（`../deepseek-harness/SKILL.md`）を直接呼ぶ。
  Google API は `bin/hydrogen-sub`・`bin/carbon-sub`・`bin/argon-sub`・
  `bin/gemini-sub`（`models.md` §0.5）。
  API 禁止・モデル固定に反する切替は行わない。適合する経路がなければ
  停止して報告する。
- Typst: `../typst-workflow/SKILL.md`。分担・委譲制約は `models.md`「Typst」。
  HPC: `~/dotfiles/agents/rules/hpc.md` と該当するクラスタのスキル。

## 回答

推奨モデル・チャネル、effort・必要な設定、根拠の節、申請要否、次の行動を
短く示す。提案だけの依頼を実行許可に広げない。
記録が必要なら正本の記録規則に従う。
