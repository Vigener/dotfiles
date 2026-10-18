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

## 判定ロジック（Phase × Task × Burn-down マッピング）

### 0. 【最優先メタ判定】研究フェーズ・勝負所（Phase-First Override）
- **判定条件**: ユーザーが「教員報告前」「論理組み立て」「数理難所」「論文章立て」「仕様策定の山場」に直面している場合。
- **ルーティング**: 週・月のリセット直後であっても**ペース配分を度外視し、最高峰知能（Argon / Sonnet 5.5 / Opus 5.5）を全力投下**する。

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

### 4. サブスク消化ペース（理想バーンダウン曲線）
- **Cursor Pro（月枠）**: 更新日の**「残り約1週間」で切れるペース**（約75%消化地点）を理想とする。ラスト1週間は Gemini系 ＋ Cursor無料系で回し、重要タスクのみ Anthropic 公式 API スポット利用。
- **Google AI Pro: Argon / Claude Quota（週枠）**: リセット日の**「残り1〜2日」で使い切るペース**を理想とする。リセット待ち中は Web版 Argon や公式 API を活用。
- **Argon の二刀流運用**: 日常門番（監査・意地悪テスト）だけでなく、**「発想・壁打ち・問いの立て直し・アーキテクチャ設計」** にも堂々と投入。週枠の余剰速度に応じて積極的に発想タスクへ回す。

### 5. クォータ消費の算定基準（2026-10-17 改訂実測値）
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


### 6. 指示記法マッピングと呼び出し手段（案C・認知ズレ防止正本）
ユーザーの自然な指示記法「`[モデル名] in [環境]`」および「`サブエージェント(inherit)`」を受け取った際のエージェント側の実行アクション規律。

| ユーザーの指定記述 | 意図する契約・枠 | エージェントの実行アクション | 禁止事項・誤爆防止 |
| :--- | :--- | :--- | :--- |
| **`opus 5.5 in agy`**<br>**`sonnet 5.5 in agy`** | **Google AI Pro**<br>（`3p-weekly` 週枠） | **Bash CLI 直接実行（完全隔離）**:<br>`agy --model claude-opus-5-5-high -p "..."`<br>`agy --model claude-sonnet-5-5-high -p "..."` | ❌ `delegate_task` で `claudeAgent` を呼ぶ（従量課金誤爆）<br>❌ `settings.json` をいじる（クラッシュ事故）<br>❌ 勝手に Cursor 枠に回す |
| **`argon in agy`**<br>**`gemini-4-argon in agy`** | **Google AI Pro**<br>（Argon 独立週枠） | **T3 サブエージェント または Bash CLI**:<br>・T3内: `delegate_task` (`antigravity` / `gemini-4-argon-high`)<br>・CLI: `agy --model gemini-4-argon-high -p "..."` | ❌ `thinking: high` でだらだらマルチターン往復（思考トークン急減防止） |
| **`flash in agy`**<br>**`gemini-3.8-flash in agy`** | **Google AI Pro**<br>（実質無料スタミナ枠） | **T3 サブエージェント または Bash CLI**:<br>・T3内: `delegate_task` (`antigravity` / `gemini-3.8-flash-high`)<br>・CLI: `agy --model gemini-3.8-flash-high -p "..."` | （超高速・1Mトークン・最も安全） |
| **`composer in cursor`**<br>**`composer 2.5 in cursor`** | **Cursor Pro 定額枠**<br>（打鍵作業員） | **Bash CLI 直接実行**:<br>`cursor-agent --model composer-2.5 "..."` | ❌ 設計や意思決定を丸投げする（品質低下） |
| **`grok in cursor`**<br>**`grok 4.7 in cursor`** | **Cursor Pro 定額枠**<br>（日常思考・監査） | **T3 サブエージェント または Bash CLI**:<br>・T3内: `delegate_task` (`cursor` / `grok-4.7`)<br>・CLI: `cursor-agent --model grok-4.7 "..."` | ❌ Cursor枠枯渇時に無駄撃ちする |
| **`opus 5.5 in cursor`**<br>**`sonnet 5.5 in cursor`** | **Cursor Pro 定額枠**<br>（Cursor側のClaude枠） | **T3 サブエージェント または Bash CLI**:<br>・T3内: `delegate_task` (`cursor` / `claude-opus-5-5`)<br>・CLI: `cursor-agent --model claude-opus-5-5 "..."` | ❌ agy に枠があるのに優先して Cursor 枠を削る |
| **`サブエージェント(inherit)`**<br>「サブエージェント(inherit)を呼び出して」 | **親エージェントと同一枠**<br>（完全モデル継承） | **親のモデルと完全に同一のモデルを起動**:<br>・親が Flash: 子も Flash<br>・親が Argon: 子も Argon<br>・親が Grok: 子も Grok | ❌ 探索タスク等で Grok 枠を無駄撃ちしない（必要時 Flash 推奨確認） |
| **`opus in claude`**<br>「公式APIを使って」<br>「claudeAgent で実行」 | **Anthropic 公式 API**<br>（従量課金・スポット） | **T3 サブエージェント または Claude Code CLI**:<br>・T3内: `delegate_task` (`claudeAgent` / `claude-opus-5-5`)<br>・CLI: `claude -p "..."` | ❌ **ユーザーから明示指示がない限り、絶対に選ばない** |

#### 環境名（`in ...`）省略時のフォールバック優先順位
ユーザーが「Opus 5.5 で敵対レビューして」のように環境を省略して指示した場合：
1. **第1優先（`in agy`）**: Google AI Pro 週枠を優先。T3 内では `delegate_task` を使わず、Bash CLI（`agy` コマンド）で実行。
2. **第2優先（`in cursor`）**: agy の Claude 週枠が枯渇している場合のみ、Cursor Pro 枠へフォールバック。
3. **第3優先（`in claude` / 公式API）**: 自動フォールバックは絶対禁止。ユーザーから「公式APIで」と明示指示がある場合のみ許可。

## 出力フォーマット（厳格なコンパクト即答ルール）

長文の講釈は避け、ユーザーが即決できるように以下のフォーマット（4項目）で即答すること。

```markdown
### 🎯 モデル選定判定
- **推奨モデル**: `agy: Gemini 4 Argon (thinking: [high/medium])` （または `cursor-agent: composer-2.5` 等）
- **推定消費**: 約 X%（11/30までの半額適用時 / 12月以降は約 Y%） ※単発換算
- **判定理由**: [Task/Flag 分類とルーティング根拠を1〜2文で簡潔に]
- **推奨アクション**: [次にどう指示するか、または打鍵役に何を投げるか]
```

---

## 7. Anthropic 5.x 世代モデル（Fable 5.1 / Opus 5.5 / Sonnet 5.5 / Haiku 5.5）選定ルール（2026-10-18 改定）

### ① 3大モデルの役割とパラメータ指針
1. **Claude Sonnet 5.5 (`claude-sonnet-5-5`)**:
   - **用途**: 高速実装、リファクタリング、pytest 自律修復ループ。
   - **推奨設定**: `effort: "medium"`, `thinking: {"type": "between_tools"}`（`high` や `max` の無駄撃ちを避ける）。
   - **指示規律**: スコープを厳格に限定し、DoD（テスト合格）まで完全自律完遂させる。
2. **Claude Opus 5.5 (`claude-opus-5-5`)**:
   - **用途**: ゼロトラスト敵対的監査（Review / Red Teaming）、数理不変量検証、論文査読耐性監査。
   - **推奨設定**: `effort: "high"`, `thinking: Adaptive`。
   - **指示規律**: 手順を指示せず、「不変条件（Invariants）」と DoD のみを渡し、自己欺瞞（Sycophancy）のない冷徹な反例探索をさせる。
3. **Claude Fable 5.1 (`claude-fable-5-1`)**:
   - **用途**: 数日間に及ぶ完全自律エージェント、数万行の大規模リファクタ、未踏の数理証明（特別顧問枠）。
   - **指示規律**: 思考を縛らず、客観的な DoD のみを与えて大域探索を委譲する。会話履歴は Append-Only を厳守。

### ② 軽量配管・ログパースにおける「Haiku vs Gemini 3.8 Flash」の判定
- **原則**: **ログパース、ファイル探索、差分抽出などの下働きは `agy: Gemini 3.8 Flash` 一択**。
- **理由**: Haiku 5.5 は 100K トークンを超えると単価が 5 倍に跳ね上がる（$0.50 / $2.50）課金の壁があり、Claude 枠を消費するのは非効率。Flash なら 1M コンテキストで実質無料かつ超高速に処理できる。
- **結論**: Haiku 5.5 はコアの 3 層（Fable / Opus / Sonnet）には組み込まず、ルーティング対象外とする。
