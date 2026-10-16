---
name: model-route
description: "タスク内容や質問に応じて、最適な AI モデル（Argon / Opus / Sonnet / Composer / Flash / Grok 等）の選定・ルーティング、推定トークン消費、およびThinkingレベルを即答判定する。「should we use argon?」「これArgon使うべき？」「これOpus使うべき？」「どのモデルで回すべき？」「モデルルーティング」「モデル判定」「model route」で発動。"
---

# `model-route` スキル

五十嵐尊人の「AIモデル選定・ルーティングのメンタルモデル（SSOT）」に基づき、ユーザーのタスクに最適なモデル・実行環境・思考深度・推定クォータ消費を即座に判定・案内するスキル。

## トリガー条件
- `/model-route [タスク内容]`
- `should we use argon?`
- `should we use opus?`
- `これArgon使うべき？`
- `これOpus使うべき？`
- `どのモデルで回すべき？`
- `モデルルーティングして`

## 参照する正本ドキュメント（SSOT）
- **正本**: `dotfiles/agents/docs/user_model_routing_mental_model.md`（または `wiki/ai-engineering/user_model_routing_mental_model.md`）
- **補足方針**: `wiki/ai-engineering/subscription_and_api_playbook_2026-10.md`

## 判定ロジック（Task × Flag マッピング）

### 1. タスク分類（Task）
- **Task: Design（設計・数理・方針・論理構造・敵対レビュー・仕様化）**:
  - **第1推奨**: `agy: Gemini 4 Argon`（Google AI Pro 独立週枠。日常門番として週100%バーンダウン対象）
    - 初回仕様策定・超難所アーキテクチャ: `thinking: high`
    - 2往復目以降の微調整・通常レビュー: `thinking: medium`
  - **巨視的ブレスト・論文通読**: `Web版 Gemini (Argon)`（agy週枠温存・無尽蔵無料）
  - **多角セカンドオピニオン（Claude視点）**: `agy: Claude Opus 5.5 (Thinking)`
  - **根本的行き詰まり・ゼロベースブレイクスルー**: `Cursor: Claude Fable 5.1`（特別顧問、Cursor温存枠）
- **Task: Implement（コード実装・打鍵・リファクタ・テスト作成）**:
  - **前段（仕様化・疑似コード）**: `agy: Gemini 4 Argon`（完全仕様化）
  - **中段（打鍵・実装）**: `Cursor: Composer 2.5` (`cursor-agent --model composer-2.5`)
  - **後段（コード監査 / Adversarial Audit）**: `agy: Gemini 4 Argon`（Diffのエッジケース・計算量レビュー）
- **Task: Extract（大量ファイル走査・ログ要約・一覧化・ディレクトリ全探索）**:
  - **唯一推奨**: `agy: Gemini 3.8 Flash`（超高速・1Mトークン・実質無料枠）

### 2. 特殊フラグ（Flag）
- **Flag: Private（機密・生活メモ・認証情報）**:
  - **絶対遵守**: `cursor-agent` 必須（Google 側の agy は絶対に使用しない）
- **Flag: Orchestration（サブエージェント並行指揮）**:
  - Cursor残枠余裕時: `Cursor: Grok 4.7`
  - Cursor残枠逼迫時: `agy: Gemini 4 Argon`

### 3. クォータ消費の算定基準（2026-10-16 基準）
- **Argon リリース記念半額割引中（〜2026年11月30日）**:
  - スポット単発（1往復）高深度タスク: **約 2〜3%**
- **Argon 通常価格期（2026年12月1日以降）**:
  - スポット単発（1往復）高深度タスク: **約 5〜6%**
- **マルチターン（同一スレッド往復）時の留意点**:
  - 入力コンテキストは Context Caching（95%オフ: $0.10/1M）で極小化されるが、毎ターンの思考トークン＋出力トークンが積算される。`thinking: high` で 3〜4 往復すると **1スレッドで 8〜15% 以上** 消費しうるため、往復時は thinking を medium に下げるか Composer に切り替える。
- **Claude Opus 5.5 (agy)**:
  - 1タスクあたり **約 10%**（重要意思決定・最終関所用）

## 出力フォーマット（厳格なコンパクト即答ルール）

長文の講釈は避け、ユーザーが即決できるように以下のフォーマット（4項目）で即答すること。

```markdown
### 🎯 モデル選定判定
- **推奨モデル**: `agy: Gemini 4 Argon (thinking: [high/medium])` （または `cursor-agent: composer-2.5` 等）
- **推定消費**: 約 X%（11/30までの半額適用時 / 12月以降は約 Y%） ※単発換算
- **判定理由**: [Task/Flag 分類とルーティング根拠を1〜2文で簡潔に]
- **推奨アクション**: [次にどう指示するか、または打鍵役に何を投げるか]
```
