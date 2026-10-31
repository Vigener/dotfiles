---
name: adversarial-review
description: >-
  既定の Breaker はループ末 Opus 5.5。T1/T2/T3 は当面呼ばない。
  Maker が Codex のあいだ Sonnet と dsh-sub を Breaker にしない。
  「レビューして」「敵対レビュー」「差分レビュー」で発動。
  hook には載せない（コスト爆発防止）。
---

# adversarial-review

## 原則

- **Maker-Breaker 異種ファミリー原則**:
  - **Maker** は W1 **`codex-sub` / Codex**（フォールバック時 **`dsh-sub` / DeepSeek**）。
  - **Breaker（既定）**: 大きなループの**最後に Opus 5.5 を 1 回**（`models.md` §3.6 **申請不要**）。**T1・T2・T3 は当面呼ばない**。
  - Codex のセルフレビューは Maker の報告であり Breaker ではない。
  - **Maker が Codex のあいだ、Sonnet 5.5 と `dsh-sub` を Breaker にしない**（同系統の二重チェックを避ける）。
  - **Gemini 3.8 Flash は敵対レビューに使わない**（探索・W2・整形・Visual QA 第一候補・yomiyasu 専用。`rules/models.md` §2.3）。
  - **Opus 5.5** は**ループ末 1 回**と**引き上げ**のみ。
  - レビューモデルとテスト作成モデルを細分化（3者分離）せず、Breaker への1回の委譲で「Diff敵対監査 ＋ 意地悪境界値テスト生成」を一括依頼してよい。
  - 迷ったら `/model-route` で決定。
- **コンテキスト完全隔離**: 親スレッドの会話履歴を一切渡さず、Diff と前提仕様のみを渡す（独立タスク/別スレッド/CLI）。
- **read-only ＆ 探索許可**: レビュアーにファイル編集はさせないが、前提文脈や関連モジュールの**自律的なファイル閲覧・grep探索（Read-only tools）は積極的に許可**する。
- **建設的批判（Constructive Critique / 代替案の義務化）**:
  - 単なる難癖・却下（REJECT）で終わらせず、**具体的代替案や上位互換の設計**を提示させる。
- **diff 優先**: 入力の主軸は git diff とする。
- **トリガー駆動**: 毎ターン回さない。
- **agy Opus は原則使わない**。**Opus 5.5 は `claude`（Team）優先**。
- **要許可モデルは呼ぶ前に確認**: Opus 5.5（**§3.6 申請不要の3用途以外**）/ Sonnet 5.5 の `high` / Fable 5.1
- **委譲チャネル**: 実装ループは `rules/delegation.md` の方針に従う。本スキル（敵対レビュー・採点）は Task / CLI 可。

## 役割分担（許可モデル）

| 役割 | モデル | 使うとき |
|---|---|---|
| **発想・問いの立て直し** | **Gemini 4 Argon (medium)** / Opus 5.5 / Fable 5.1 | Opus・Fable は **models.md §3.6 により要申請**（発想のみ） |
| **ループ最終レビュー（Breaker）** | **Opus 5.5**（1 回） | `models.md` §3.6 申請不要 |
| T1 / T2 / T3 | — | 当面なし |

**high の同役二重は禁止**。ループ末 Opus 5.5 は 1 回（§3.6 申請不要）。

## 手順（既定）

1. 大きなループの Verifier 前後で、**Opus 5.5 に 1 回** diff + 前提を渡す（§3.6 申請不要）。
   - スコープ: `~/dotfiles/agents/rules/delegation.md` の「敵対レビューのスコープ」。
2. **モデル名を先頭に（必須・呼び出し前）**:

```text
レビュワーモデルとして、次を呼び出します:
- 一次: Opus 5.5（Team）
- 経路: claude -p | claudeAgent
- ティア: ループ末 Breaker
```

3. 差分を取る:

```bash
git diff --stat
git diff > /tmp/adv-review.diff
```

4. **Opus 5.5** でレビューを走らせる（`claude -p` 等）。プロンプトに read-only・severity フォーマット・建設的批判を含める。

5. triage: blocker/major だけ修正。nit は溜めて無視可。
6. 結果を `inbox/REVIEWS/` または sandbox `docs/logs/` に残す（任意）。

## 参考: T1 を本人が再開したとき（既定手順外）

Maker が **Codex** で、本人が **T1 相当の軽い diff 監査**を再開するときだけ。既定の Breaker 手順の代わりにはしない。

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

**headless の `dsh-sub` に read-only 専用モードは無い**。編集禁止はプロンプトとオーケストレータ側の triage で守る（スキル `deepseek-harness`）。

## hook にしない理由

`stop` 毎回発火はタイムアウト・コスト爆発を招く。本スキルを Loop の Verifier 前後で明示呼び出しする。

## 関連

- モデル方針: `agents/rules/models.md` / `agents/docs/routing.md`
- W1: スキル `codex-harness` / 控え `deepseek-harness`
