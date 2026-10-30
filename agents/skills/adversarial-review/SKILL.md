---
name: adversarial-review
description: >-
  Cursor auto-review の代わりに dsh-sub / Grok 4.7 / Sonnet 5.5 / Opus 5.5 で敵対レビューする。
  「レビューして」「敵対レビュー」「差分レビュー」で発動。
  hook には載せない（コスト爆発防止）。
---

# adversarial-review

## 原則

- **Maker-Breaker 異種ファミリー原則**:
  - 実装（W1 **`dsh-sub` / DeepSeek**）を行った Maker と**異なるモデルファミリー／プロバイダ**を Breaker に選定する。
  - **Gemini 3.8 Flash は敵対レビューに使わない**（探索・W2・整形・Visual QA・yomiyasu 専用。`rules/models.md` §2.3）。
  - **T1**: 既定 **`dsh-sub`**（軽い diff）。**直前 Maker が W1 `dsh-sub` なら Sonnet 5.5 (medium)**。
  - **T2**: **Grok 4.7**（非 Fast）第一候補（RES-23 試行・Claude Team 分散）。
  - **T3**: **Sonnet 5.5 (medium)**。
  - **Opus 5.5** は**ループ末 1 回**と**引き上げ**のみ。通常の Breaker にしない。
  - レビューモデルとテスト作成モデルを細分化（3者分離）せず、Breaker への1回の委譲で「Diff敵対監査 ＋ 意地悪境界値テスト生成」を一括依頼してよい。
  - 迷ったら `/model-route` で決定。
- **コンテキスト完全隔離**: 親スレッドの会話履歴を一切渡さず、Diff と前提仕様のみを渡す（独立タスク/別スレッド/CLI）。
- **read-only ＆ 探索許可**: レビュアーにファイル編集はさせないが、前提文脈や関連モジュールの**自律的なファイル閲覧・grep探索（Read-only tools）は積極的に許可**する。
- **建設的批判（Constructive Critique / 代替案の義務化）**:
  - 単なる難癖・却下（REJECT）で終わらせず、**具体的代替案や上位互換の設計**を提示させる。
- **diff 優先**: 入力の主軸は git diff とする。
- **トリガー駆動**: 毎ターン回さない。
- **大きなループの最後**: **Opus 5.5 で 1 回**（`models.md` §3.6 **申請不要**）。T3 監査のあとに回す。
- **agy Opus は原則使わない**。**Opus 5.5 は `claude`（Team）優先**。
- **要許可モデルは呼ぶ前に確認**: Opus 5.5（**§3.6 申請不要の3用途以外**・**models.md §3.6 により要申請**）/ Sonnet 5.5 の `high`（**models.md §3.6 により要申請**）/ Fable 5.1（**models.md §3.6 により要申請**）
- **effort は既定 medium**: T2–T3 は medium。ループ末 Opus 5.5 は high（§3.6 申請不要）。
- **委譲チャネル**: 実装ループは `rules/delegation.md` の方針に従う。本スキル（敵対レビュー・採点）は Task / CLI 可。

## 役割分担（許可モデル）

| 役割 | モデル | 使うとき |
|---|---|---|
| **発想・問いの立て直し** | **Gemini 4 Argon (medium)** / Opus 5.5 / Fable 5.1 | Opus・Fable は **models.md §3.6 により要申請**（発想のみ。設計正本に Argon を使わない） |
| **敵対レビュー T2** | **Grok 4.7**（非 Fast） | RES-23 試行 |
| **敵対レビュー T3** | **Sonnet 5.5 (medium)** | 節目・major+ |
| **ループ最終レビュー** | **Opus 5.5**（1 回） | `models.md` §3.6 申請不要 |
| 日常・中間（T1） | **`dsh-sub`**（1017） | 軽い diff。W1 直後は Sonnet 5.5 (medium) |

**high の同役二重は禁止**。ループ末 Opus 5.5 は 1 回（§3.6 申請不要）。Sonnet 5.5 を発想役にしない。

## ティア

| ティア | いつ | 渡すもの | モデル例 |
|---|---|---|---|
| T1 | コミット前・軽い草案 | `git diff` のみ | **`dsh-sub`**。W1 直後は Sonnet 5.5 (medium) |
| T2 | 主張・設計判断・status 更新 | diff + 関連1–2ファイル | **Grok 4.7**（非 Fast） |
| T3 | T2 で major+、または節目 | 広め | **Sonnet 5.5 (medium)**。ループ末 Opus 5.5 は手順 4 以降 |

T3 トリガー例: 主張が変わった / hooks・スキル変更 / 論文に載る言い方 / 計画の前提が大きく変わった。

## 手順

1. ティアを決める（迷ったら T1）。T2 は **Grok 4.7**、T3 は **Sonnet 5.5 (medium)**。ループ末 **Opus 5.5** は §3.6 申請不要。
   - スコープ: `~/dotfiles/agents/rules/delegation.md` の「敵対レビューのスコープ」。
2. **モデル名を先頭に（必須・呼び出し前）**:
   - Cursor Task: `description` を `{通称} {作業}` にする（例: `Grok T2 diff review`）。
   - `dsh-sub` / agy / claude / cursor: 起動**直前**にチャットへ宣言。

```text
レビュワーモデルとして、次を呼び出します:
- 一次: <model id>
- 二次（使うときのみ）: <model id>
- 経路: CLI | Cursor Task
- ティア: T1|T2|T3
```

3. 差分を取る:

```bash
git diff --stat
git diff > /tmp/adv-review.diff
```

4. レビューを走らせる。

T1（`dsh-sub`）例。**headless の `dsh-sub` に read-only 専用モードは無い**。編集禁止はプロンプトとオーケストレータ側の triage で守る（スキル `deepseek-harness`）。

```bash
{ echo "あなたは敵対的レビュアー。以下 diff に対し（編集・ファイル書き込み禁止）:
1. 反例を1つ以上（なければ「なし」）
2. 暗黙の前提と崩れる条件
出力フォーマット:
- severity: blocker|major|minor|nit
- location:
- claim / evidence:
- suggested_fix:
- better_alternative: （あれば）
総評・お世辞禁止。"; cat /tmp/adv-review.diff; } \
  | dsh-sub --repo . --prompt -
```

T2 は Grok 4.7（同等プロンプト・非 Fast）。T3 は Sonnet 5.5 (medium)。ループ末は **Opus 5.5 1 回**（§3.6 申請不要）。

5. triage: blocker/major だけ修正。nit は溜めて無視可。
6. 結果を `inbox/REVIEWS/` または sandbox `docs/logs/` に残す（任意）。
7. 設計の立て直しが必要なら、**別ターンで Opus 5.5 / Fable 5.1 / Argon（発想）** を使う（レビューと混ぜない。Opus・Fable は §3.6 要申請）。

## hook にしない理由

`stop` 毎回発火はタイムアウト・コスト爆発を招く。本スキルを Loop の Verifier 前後で明示呼び出しする。

## 関連

- モデル方針: `agents/rules/models.md` / `agents/docs/routing.md`
- `dsh-sub` 契約: スキル `deepseek-harness`
