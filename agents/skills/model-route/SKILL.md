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
本3タスクでは Hydrogen / Grok の積極利用を本人承認済み。Grok の探索・案出し・
比較検討・範囲を切った実装も許可する（従来の用途制限へのタスク限定例外）。
担当が全実装・探索を抱えず、切り出せる実装は Terra / Sonnet、検索・抽出は
Luna / Haiku / Hydrogen 等へ渡せる。ライブ提供確認・契約境界・総消費を守る。

**暫定ペア運用（2026-11-16）**: 正本 `models.md` §0.4 を優先する。
Argon を判断材料・発想・監査へ出すときは原則 Hydrogen と組み合わせる。
Grok + Hydrogen も許可済み用途で試行候補。Hydrogen の消費速度が問題に
なれば Argon + Grok 等へ見直し得るが、自動切替せず本人と相談する。
Carbon のサブスク解放を待機条件にしない。Hydrogen 単独調査の常時二重化や
ペアの合意による正しさ保証ではなく、役割・制約・不一致の扱いは正本に従う。

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
     テキストの W2・Extract・整形・yomiyasu 向き。**既定 `high`（無指定で可、
     軽作業 `low` 可）**。エージェントは `hydrogen-sub` のみ。ツール探索・
     PNG 目視は `models.md` §2.3 の非 Google 経路。人間が直接開いた
     `antigravity` スレッドでも同じ既定。`xhigh` は無意味な引き上げを禁止し、
     必要時は理由 1 行記録で事後報告可。
   - **Argon (`gemini-4-argon`)**: 低ハルシネーション（`AA-Omniscience`）・
     図表読解・科学ベンチでなお優位。人間直操作の独立週枠は発想と暫定監査
     （`models.md` §2.5）に集中する。エージェントは `argon-sub` に限る。
     **有料 API では最小限に抑える**。
   - **Carbon (`gemini-4-carbon`)**: 限界を試す作業（複雑多段デバッグ・
     開かれた科学的探求）。設計・仕様・W1・ループ頭と引き上げは従来どおり
     Opus / Codex であり、Carbon へ付け替えない。エージェントは `carbon-sub`。
2. **チャネル境界（エージェントは Antigravity を起動しない）**:
   - エージェントは `delegate_task` の `providerInstanceId: "antigravity"` と
     `agy -p` / `agy acp` を使わない（`antigravity` 自身からの `delegate_task`
     も含む）。Gemini は `hydrogen-sub` / `argon-sub` / `carbon-sub` /
     `flash-sub`。
   - `antigravity` は人間が T3 UI で直接開いたルートスレッド専用
     （同スレッド内の `invoke_subagent` は `Model: "inherit"` のみ）。
   - Carbon が `antigravity` に掲載されても、エージェントはサブスク枠を呼ばない。
     掲載確認のために `orchestrator_capabilities` で `antigravity` を開かない。
     `cursor` に出ていても選ばない。人間が自分でスレッドを開くときだけ、
     掲載後のサブスクを使える。
3. **API（`gemini-sub` 系）と枠切れ**:
   - `~/.config/gemini-sub/.env` は Prepay / オートチャージ OFF が確認済み
     （`models.md` §0.5）。エージェント適合タスクでは都度確認なしで呼んでよい。
   - **枯渇時**: API が `429` / `RESOURCE_EXHAUSTED` なら停止し、`agy` へ
     自動逃避しない。人間直操作の Argon 週枠を使い切ったあとの順
     （その人間の `antigravity` Hydrogen / Web Argon → 必要時 `argon-sub`）は
     人間が操作するときだけ（`models.md` §0.5）。
   - **API 利用時の主軸**: `hydrogen-sub` または `carbon-sub`（限界を試す難所のみ）を
     優先し、`argon-sub` の乱発を避ける。Carbon は `--timeout 900`・圧縮プロンプトを
     維持し、タイムアウト時は圧縮再試行または `argon-sub` / `hydrogen-sub` へ退避する。
   - **effort**: Hydrogen は既定 `high`（軽作業 `low` 可、`xhigh` は無意味な
     引き上げ禁止・理由 1 行記録で事後報告可）。Argon / Carbon は既定 `medium`、
     API の `high` 引き上げも無意味禁止・理由 1 行記録で事後報告可（`models.md`
     §0.5・§1.2）。
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
