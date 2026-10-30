---
name: adversarial-review
description: >-
  Cursor auto-review の代わりに Sonnet / Opus（＋必要時 Grok 4.7）で敵対レビューする。
  「レビューして」「敵対レビュー」「agyで見て」「差分レビュー」で発動。
  hook には載せない（コスト爆発防止）。
---

# adversarial-review

## 原則

- **Maker-Breaker 異種ファミリー原則**:
  - 実装（W1 **`dsh-sub` / DeepSeek**）を行った Maker と**異なるモデルファミリー／プロバイダ**を Breaker に選定する。
  - 日常例: Maker が DeepSeek なら Breaker は **Sonnet 5.5**（Anthropic）／追加席に **Grok 4.7**（xAI・非 Fast）や **Gemini Flash**（Google）。Grok 4.6 と 4.7 は同一ファミリー。
  - オーケストレーターが Opus のとき、Breaker は Google 系（Flash）や xAI（Grok）で組む（Sonnet+Opus の本流レビューは別ラウンドとして扱う）。
  - レビューモデルとテスト作成モデルを細分化（3者分離）せず、Breaker への1回の委譲で「Diff敵対監査 ＋ 意地悪境界値テスト生成」を一括依頼してよい。
  - 迷ったら `/model-route` で決定。
- **コンテキスト完全隔離**: 親スレッドの会話履歴を一切渡さず、Diff と前提仕様のみを渡す（独立タスク/別スレッド/CLI）。
- **read-only ＆ 探索許可**: レビュアーにファイル編集はさせないが、前提文脈や関連モジュールの**自律的なファイル閲覧・grep探索（Read-only tools）は積極的に許可**する。
- **建設的批判（Constructive Critique / 代替案の義務化）**:
  - 単なる難癖・却下（REJECT）で終わらせず、**具体的代替案や上位互換の設計**を提示させる。
- **diff 優先**: 入力の主軸は git diff とする。
- **トリガー駆動**: 毎ターン回さない。
- **大きなループの最後**: **Opus 5.5 で 1 回**レビューする（§3.6 **申請不要**）。本流の Sonnet medium 監査のあとに回す。
- **agy Opus は原則使わない**。**Opus 5.5 は `claude`（Team）優先**。
- **要許可モデルは呼ぶ前に確認**: Opus 5.5（**§3.6 申請不要の3用途以外**）/ Sonnet 5 の `high` / Fable 5.1
- **effort は既定 medium**: ルーブリック・DoD・差分を渡せる監査は Sonnet medium で足りる。ループ末 Opus レビューは high（§3.6 申請不要）。
- **委譲チャネル**: 実装ループは `rules/delegation.md` の方針に従う。本スキル（敵対レビュー・採点）は Task / CLI 可。

## 役割分担（許可モデル）

| 役割 | モデル | 使うとき |
|---|---|---|
| **発想・問いの立て直し** | **Argon medium**（agy） / Opus 5.5 / Fable 5.1（Opus・Fable は §3.6 要申請） | アイデアのみ。**設計・仕様の正本には Argon を使わない** |
| **敵対レビュー（本流）** | **Sonnet 5.5 medium** | T1–T3、Diff 監査。必要なら **Grok 4.7**（非 Fast） |
| **ループ最終レビュー** | **Opus 5.5**（1 回・§3.6 申請不要） | 大きなループの締め |
| 日常・中間（T1） | `pi` / Gemini Flash | 軽い diff のみ |

**high の同役二重は禁止**。本流は Sonnet medium。ループ末 Opus は 1 回（§3.6 申請不要）。発想は Argon / Opus / Fable。Sonnet を発想役にしない。

## ティア

| ティア | いつ | 渡すもの | モデル例 |
|---|---|---|---|
| T1 | コミット前・軽い草案 | `git diff` のみ | `pi` / `agy` gemini-flash |
| T2 | 主張・設計判断・status 更新 | diff + 関連1–2ファイル | Sonnet 5 medium |
| T3 | T2 で major+、または節目 | 広め | **Sonnet 5 medium**（必要なら Grok 4.7）。ループ末 Opus は手順 4 以降 |

T3 トリガー例: 主張が変わった / hooks・スキル変更 / 論文に載る言い方 / 計画の前提が大きく変わった。

## 手順

1. ティアを決める（迷ったら T1）。T3 なら **Sonnet medium** で走らせる。ループ末 **Opus** は §3.6 申請不要（呼ぶ前に手順 2 の宣言を更新）。
   - スコープ: `~/dotfiles/agents/rules/delegation.md` の「敵対レビューのスコープ」。
2. **モデル名を先頭に（必須・呼び出し前）**:
   - Cursor Task: `description` を `{通称} {作業}` にする（例: `Sonnet T2 diff review`）。
   - agy / pi / claude: 起動**直前**にチャットへ宣言。

```text
レビュワーモデルとして、次を呼び出します:
- 一次: <model id>（例: agy claude-sonnet-5-5-medium）
- 二次（使うときのみ）: <model id>（例: claude Opus 5.5 high）
- 追加（任意）: Grok 4.7（fastMode false）
- 経路: CLI | Cursor Task
- ティア: T1|T2|T3
```

3. 差分を取る:

```bash
git diff --stat
git diff > /tmp/adv-review.diff
```

4. レビューを走らせる（T3 は Sonnet。ループ末は **Opus 1 回**・§3.6 申請不要）。

5. triage: blocker/major だけ修正。nit は溜めて無視可。
6. 結果を `inbox/REVIEWS/` または sandbox `docs/logs/` に残す（任意）。
7. 設計の立て直しが必要なら、**別ターンで Opus / Fable / Argon（発想）** を使う（レビューと混ぜない）。

## hook にしない理由

`stop` 毎回発火はタイムアウト・コスト爆発を招く。本スキルを Loop の Verifier 前後で明示呼び出しする。

## 関連

- モデル方針: `agents/rules/models.md` / `agents/docs/routing.md`
- 統合提案: `research-brain/inbox/agent_ops_proposals_2026-07-31/00_synthesis.md`
