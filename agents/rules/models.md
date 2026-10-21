# モデル呼び出し（役割・クォータ）

正本: `research-brain/wiki/ai-engineering/user_model_routing_mental_model.md`
（各環境スナップショット: `~/dotfiles/agents/docs/user_model_routing_mental_model.md`）
および `subscription_and_api_playbook_2026-10.md`。

HPC 境界は `rules/hpc.md` を参照。

## 0. クォータの確認（数値を本文に書かない）

- 残量・リセット時刻・消費ペースは次で取得する:
  `~/dotfiles/bin/update-ai-usage --format markdown --no-notify --no-write-runcat`
- **このファイルに残量（%・$）を書かない。** 数値は日単位で陳腐化するため、判断には必ずコマンドの現在値を引用する。
- agy の枠は「Gemini」「Claude/GPT」「Argon」の3グループに分かれる。**Argon は別枠**。

## 1. Gemini 4 Argon 最優先 ＆ 週次バーンダウン規律（agy 独立週枠）

- agy に Google AI Pro 契約者向けの「Argon 独立週枠（100%別枠）」が正式常備。
- 週枠は繰り越されないため **「Use it or lose it（毎週100%使い切る）」**。温存心理を撤廃し、**日常4大門番（①実装前仕様化、②Diff敵対監査、③意地悪境界値テスト生成、④批判的文献読解）** に最優先で投入する。
- agy 側の週枠消化後は、Google AI Pro 付属の Web 版 Argon（無料）へフォールバックして使い倒す。

## 2. Cursor Pro クォータ防護と Composer 打鍵特化

- Grok 4.7 への日常の思考・設計丸投げを停止し、agy Argon へオフロード。Cursor 側は **Composer 2.5 (`agent --model composer-2.5`)** による打鍵・量産に特化させる。
- **Cursor からの Fable 5.1 / Opus 5.5 の呼び出しは厳禁（核ボタン・1発25%/$5蒸発事故の教訓）**。

## 3. Claude（Team シート優先）

- **認証の確認**: `claude auth status` が `subscriptionType: "team"` なら、`claude` CLI と T3 の `claudeAgent` は **Team シート（サブスク）** で動く。従量 API ではない。
- **優先順位**: Team シート > 各サブスク枠（agy / Cursor）> 従量 API。
- **API に切り替わる条件**: `ANTHROPIC_API_KEY` が設定されている、または `CLAUDE_CODE_SIMPLE=1` を使うと従量 API になる。使う前に `claude auth status` と環境変数を確認する。
- **Team 枠を使い切った場合**: Anthropic 公式 API を検討してよいが、API を使うならまず安価な DeepSeek 等を優先する。
- Claude 特有の自走が必要な局面では Sonnet 5.5 / Opus 5.5 を Team 枠で使う。`claudeAgent` は `binaryPath: claude` を叩くため、CLI と同じ認証を共有する。

## 4. ゴール固定・敵対レビュー

- 長作業の開始時はスキル `goal`。
- 意地悪テスト生成・敵対的監査は「Maker-Breaker原則（実装と検証は異種モデル・コンテキスト完全隔離）」を遵守すること。選定と詳細手順はスキル `adversarial-review`（`~/dotfiles/agents/skills/adversarial-review/SKILL.md`）および `model-route` を参照。
