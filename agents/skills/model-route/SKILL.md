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
- **研究専用フォーメーション正本**: `projects/gradB/model_formation_post_interim.md`
- **補足方針**: `wiki/ai-engineering/subscription_and_api_playbook_2026-10.md`

## 判定ロジック（Task × Flag マッピング）

### 1. タスク分類（Task）
- **Task: Design / Adversarial Audit（設計・数理・敵対レビュー・意地悪テスト生成）**:
  - **日常敵対レビュー＆意地悪テスト（Maker-Breaker 異種クロスファミリー）**:
    - 親が Google系（Gemini 3.8 Flash等）: `Cursor: Grok 4.7`（第1候補）
    - 親が xAI系（Grok 4.7等）: `agy: Gemini 3.8 Flash`（第1候補）
    - 候補拡張: `Claude Sonnet 5.5`, `DeepSeek V4 Pro / V4.1 Flash`
    - ※テスト作成役とレビュー役を分ける（3者分離）のではなく、「Breaker役」として1つの独立タスクに集約委譲。
  - **勝負所・節目・週枠バーンダウン**: `agy: Gemini 4 Argon`（Google AI Pro 独立週枠）
    - 初回仕様策定・超難所アーキテクチャ: `thinking: high`
    - 2往復目以降の微調整・重要レビュー: `thinking: medium`
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

### 3. 研究コンテキスト専用オーバーライド（gradB / b4-qcut-workbench）
※対象: 量子回路切断、分散状態ベクトル、Miyabi、卒論、`b4-qcut-workbench` のタスク

- **正本参照先**: `projects/gradB/model_formation_post_interim.md`
- **時期別ゲート**:
  - **中間報告書の提出完了まで（教員のGoサインが出て提出完了をユーザーから受け取るまで）**:
    新機能・探索・最適化アルゴリズム・第5章の検討は **原則凍結**。教員赤入れ時のみ Argon (medium 1往復)、その他は Flash（組版・差分抽出）に限定し、中間報告書完成を最優先とする（最終締切 10/23 17:00）。
  - **中間報告書の提出完了後（`now/TODO.md` 等で完了宣言後〜12月）**:
    以下の確定モデル編成（フェーズA/B）へ移行する。
- **確定モデル編成（役割・制約）**:
  1. **思考の主砲（設計・数理・探索）**: `agy: Gemini 4 Argon`（Google AI Pro 週枠、平均5%/回、週15〜20回バーンダウン運用）
     - 密疎クラスタ回路仕様、境界探索、アルゴリズム設計。
     - 週後半に枠が余ればテスト仕様・境界値監査に投下してバーンダウン（仕事の無理な発明は禁止）。
  2. **独立監査（Tier 2 / 自己監査の完全禁止）**: **`agy: Claude Sonnet 5.5 (Thinking)`**（約5%/回）
     - **絶対遵守**: Argon が生成した仕様・コード・評価関数のレビューは、Argon 自身ではなく必ず agy Sonnet 5.5 に通す。
  3. **マクロ審問（Tier 3 / 節目防壁）**: `agy: Claude Opus 5.5 (Thinking)`（約10%/回）
     - 週1回の教員面談前アジェンダ、章立て、研究の軸折れ・論理破綻の検知専用。
  4. **打鍵・実装**: `Cursor: Composer 2.5` (`$0.07/task`)
     - 機械的コーディングに徹する。Grok にコードを書かせない（Cursor枠枯渇防止）。
  5. **機械的採点（客観的評価器）**: **`ローカル Python (pytest / ECDF)`**
     - LLM にシミュレータ役や採点役を演じさせない（壁打ちループ防止）。必ず Python コードで決定論的スコアリングを行う。
  6. **情報抽出・同期**: `agy: Gemini 3.8 Flash`（無料・1Mコンテキスト）
     - Miyabi ログ集計、Wiki同期、ファイル探索。
  7. **特別顧問（厳格温存）**: `Cursor: Claude Fable 5.1`（$5/回）
     - 根本的な軸崩壊時のみ召喚。日常使用禁止。

### 4. クォータ消費の算定基準（2026-10-17 改訂実測値）
- **Argon リリース記念半額割引中（〜2026年11月30日）**:
  - スポット単発（1往復）高深度タスク: **約 3%**
  - マルチターンまたは深層思考平均: **約 5%**（週15〜20回バーンダウン）
- **Argon 通常価格期（2026年12月1日以降）**:
  - スポット単発（1往復）高深度タスク: **約 6%**
  - マルチターンまたは深層思考平均: **約 8〜10%**（週10〜12回運用）
- **マルチターン（同一スレッド往復）時の留意点**:
  - 入力コンテキストは Context Caching（95%オフ: $0.10/1M）で極小化されるが、毎ターンの思考トークン＋出力トークンが積算される。`thinking: high` で 3〜4 往復すると **1スレッドで 8〜15% 以上** 消費しうるため、往復時は thinking を medium に下げるか Composer に切り替える。
- **Claude Sonnet 5.5 (agy)**:
  - 1タスクあたり **約 5%**（日常独立監査用・自己監査防止門番）
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
