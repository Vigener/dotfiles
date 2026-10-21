---
name: adversarial-review
description: >-
  Cursor auto-review の代わりに agy/pi（＋許可時 Sonnet 5 high / Opus / Fable）で敵対レビューする。
  「レビューして」「敵対レビュー」「agyで見て」「差分レビュー」で発動。
  hook には載せない（コスト爆発防止）。
---

# adversarial-review

## 原則

- **Maker-Breaker 異種ファミリー原則**:
  - 実装・正常系テストを行った Maker（親オーケストレータ）と**異なるモデルファミリー／プロバイダ**を Breaker に選定する（自己盲点・Sycophancy の物理排除）。
  - 日常例: 親が Google系（Gemini 3.8 Flash等）なら Breaker は xAI系（Grok 4.7 等）／親が xAI系（Grok 4.7）なら Breaker は Google系（Flash等）。節目・難所は Argon / Sonnet 5.5 / DeepSeek V4 系へエスカレーション。迷ったら `/model-route` で決定。
  - レビューモデルとテスト作成モデルを細分化（3者分離）せず、Breaker への1回の委譲で「Diff敵対監査 ＋ 意地悪境界値テスト生成」を一括依頼する。
- **コンテキスト完全隔離**: 親スレッドの会話履歴を一切渡さず、Diff と前提仕様のみを渡す（独立タスク/別スレッド/CLI）。
- **read-only ＆ 探索許可**: レビュアーにファイル編集はさせないが、前提文脈や関連モジュールの**自律的なファイル閲覧・grep探索（Read-only tools）は積極的に許可**する（Diff単体で文脈誤認するのを防ぐ）。
- **建設的批判（Constructive Critique / 代替案の義務化）**:
  - 単なる難癖・却下（REJECT）・重箱の隅突きで終わらせず、**「よりシンプル・堅牢・エレガントになる具体的代替案（Alternative Proposal）や上位互換の設計」** を積極的に提示させる。
- **diff 優先**: 入力の主軸は git diff とするが、探索が必要なら関連ファイルも参照させる。
- **トリガー駆動**: 毎ターン回さない
- **agy Opus 禁止**（Google AI Pro が即 5h limit）
- **要許可モデルは呼ぶ前に確認**: Sonnet 5 の `high` / Opus 5.5 / Fable 5.1（Sonnet 5 の medium は既定なので不要）
- **effort は既定 medium**: ルーブリック・DoD・差分を渡せる監査と採点は medium で足りる。high は「何が良いか自体を決める」局面だけ（`rules/models.md` 3.5）。
- **委譲チャネル**: 実装ループは `rules/delegation.md` の方針に従う。本スキル（敵対レビュー・採点）は Task / CLI 可。

## 役割分担（許可モデル）

| 役割 | モデル | 使うとき |
|---|---|---|
| **発想・方針・問いの立て直し** | **Opus 5.5 / Fable 5.1**（要許可） | 設計の壁打ち、研究の言い方、アーキ選択。レビュー役にはしない。`claude` 経由（Cursor は核ボタンで禁止、agy の Opus は 5h limit で禁止） |
| **レビュー分析・計画の穴・採点統合** | **Argon medium + Sonnet 5 medium**（別ファミリー2本立て） | T3 の敵対レビュー、ルーブリック横断、複数ラウンドの統合判定 |
| 日常・中間 | pi / agy Flash·Pro / Sonnet 4.6 | T1–T2。許可不要で足りることが多い |

**high の同役二重は禁止。medium の別ファミリー2本立ては可（推奨）**。発想は Opus / Fable、監査は Argon + Sonnet。Sonnet を発想役にしない。

## ティア

| ティア | いつ | 渡すもの | モデル例 |
|---|---|---|---|
| T1 | コミット前・軽い草案 | `git diff` のみ | `pi` (kimi-k3 等) / `agy` gemini-flash |
| T2 | 主張・設計判断・status 更新 | diff + 関連1–2ファイル | `agy` gemini-pro / claude-sonnet-4-6 |
| T3 | T2 で major+、または節目 | 広め | **Argon medium + Sonnet 5 medium の2本立て**。Sonnet 5 の `high` を使うときだけ許可を取る。発想の再設計が必要なら別途 **Opus 5.5 / Fable 5.1** を許可申請（レビュー役ではない） |

T3 トリガー例: 主張が変わった / hooks・スキル変更 / 論文に載る言い方 / 計画の前提が大きく変わった。

## 手順

1. ティアを決める（迷ったら T1）。T3 なら **Argon medium + Sonnet 5 medium の2本立て**で走らせる（Sonnet 5 の `high` を使うときだけ許可を取る）。
   - スコープ: `~/dotfiles/agents/rules/delegation.md` の「敵対レビューのスコープ」。正本に無い使用上限（Fable 1日1回・別BRIEF別日必須等）を発明しない。「同日同問」は Fable↔Opus／同役二重のみ。疑わしい制限は nit＋正本引用必須（major にしない）。
2. **モデル名を先頭に（必須・呼び出し前）**:
   - Cursor Task: `description` を `{通称} {作業}` にする（例: `Gemini Flash T1 diff review`）。UI に通称が出る。チャット宣言は省略可。
   - agy / pi / herdr: 起動**直前**にチャットへ次を出す。宣言なしで呼んではならない。

```text
レビュワーモデルとして、次を呼び出します:
- 一次: <実コマンドに渡す model id>（例: agy claude-sonnet-4-6）
- 二次（使うときのみ）: <model id>（例: なし / pi kimi-k3）
- 経路: CLI | Cursor Task | herdr pane
- ティア: T1|T2|T3
```

   herdr ペイン必須にはしない（宣言で可視性を担保）。ペインを使う場合も宣言は省略しない。
3. 差分を取る:

```bash
git diff --stat
git diff > /tmp/adv-review.diff
```

4. レビューを走らせる（例・T1）:

```bash
pi --model opencode-go/kimi-k3 --thinking medium --no-tools -p "$(cat <<'EOF'
あなたは敵対的レビュアー。以下の diff に対し:
1. 反例を1つ以上（なければ「なし」）
2. 暗黙の前提と崩れる条件
3. 研究なら: 結論がデータから導けるか、再現コマンド、言ってよい/ダメ逸脱
出力フォーマット:
- severity: blocker|major|minor|nit
- location:
- claim / evidence: 欠陥の指摘と論理的根拠
- suggested_fix: 修正案
- better_alternative: （あれば）よりシンプル・堅牢になる根本的代替案・上位互換の設計アイデア
総評・お世辞禁止。
EOF
)
$(cat /tmp/adv-review.diff)"
```

T3 では同等プロンプトを **Argon medium と Sonnet 5 medium の2本**に渡し、指摘集合の差を見る（high 1本を既定にしない）。呼び出す前に手順2の宣言を更新すること。

5. triage: blocker/major だけ修正。nit は溜めて無視可。
6. 結果を `inbox/REVIEWS/` または sandbox `docs/logs/` に残す（任意）。ログ先頭にも実際に使った model id を1行残す。
7. レビュー後に設計の立て直しが必要なら、**別ターンで Opus 5.5 / Fable 5.1 の許可**を取り発想役に回す（レビューと混ぜない）。

## hook にしない理由

`stop` 毎回発火はタイムアウト・コスト爆発を招く。本スキルを Loop の Verifier 前後で明示呼び出しする。

## 関連

- モデル方針: `research-brain/wiki/ai-engineering/cursor_model_routing.md`
- 統合提案: `research-brain/inbox/agent_ops_proposals_2026-07-31/00_synthesis.md`
