---
name: adversarial-review
description: >-
  Cursor auto-review の代わりに agy/pi（＋許可時 Terra）で敵対レビューする。
  「レビューして」「敵対レビュー」「agyで見て」「差分レビュー」で発動。
  hook には載せない（コスト爆発防止）。
---

# adversarial-review

## 原則

- **read-only**: レビュアーに編集させない
- **diff 優先**: 全文は T3 のみ
- **トリガー駆動**: 毎ターン回さない
- **agy Opus 禁止**（Google AI Pro が即 5h limit）
- **要許可モデルは呼ぶ前に確認**: Cursor Sonnet 5 / GPT-5.6 Terra

## 役割分担（許可モデル）

| 役割 | モデル | 使うとき |
|---|---|---|
| **発想・方針・問いの立て直し** | **Sonnet 5**（要許可） | 設計の壁打ち、研究の言い方、アーキ選択。レビュー役にはしない（同役二重呼び出し禁止） |
| **レビュー分析・計画の穴・採点統合** | **GPT-5.6 Terra**（要許可） | T3 の敵対レビュー、ルーブリック横断、複数ラウンドの統合判定 |
| 日常・中間 | pi / agy Flash·Pro / Sonnet 4.6 | T1–T2。許可不要で足りることが多い |

Sonnet 5 と Terra を**同じレビュー役で並べない**（コスト倍・役割重複）。発想は Sonnet、監査は Terra。

## ティア

| ティア | いつ | 渡すもの | モデル例 |
|---|---|---|---|
| T1 | コミット前・軽い草案 | `git diff` のみ | `pi` (kimi-k3 等) / `agy` gemini-flash |
| T2 | 主張・設計判断・status 更新 | diff + 関連1–2ファイル | `agy` gemini-pro / claude-sonnet-4-6 |
| T3 | T2 で major+、または節目 | 広め | **許可時: GPT-5.6 Terra（分析レビュー）**。未許可なら agy Sonnet 4.6 で止める。発想の再設計が必要なら別途 **Sonnet 5** を許可申請（レビュー役ではない） |

T3 トリガー例: 主張が変わった / hooks・スキル変更 / 論文に載る言い方 / 計画の前提が大きく変わった。

## 手順

1. ティアを決める（迷ったら T1）。T3 なら Terra 許可を先に取る。
2. 差分を取る:

```bash
git diff --stat
git diff > /tmp/adv-review.diff
```

3. レビューを走らせる（例・T1）:

```bash
pi --model opencode-go/kimi-k3 --thinking medium --no-tools -p "$(cat <<'EOF'
あなたは敵対的レビュアー。以下の diff に対し:
1. 反例を1つ以上（なければ「なし」）
2. 暗黙の前提と崩れる条件
3. 研究なら: 結論がデータから導けるか、再現コマンド、言ってよい/ダメ逸脱
出力のみ:
- severity: blocker|major|minor|nit
- location:
- claim / evidence / suggested_fix
総評禁止。
EOF
)
$(cat /tmp/adv-review.diff)"
```

T3（許可後）は同等プロンプトを **GPT-5.6 Terra** に渡し、可能なら T2 結果との差分だけ追加指摘させる。

4. triage: blocker/major だけ修正。nit は溜めて無視可。
5. 結果を `inbox/REVIEWS/` または sandbox `docs/logs/` に残す（任意）。
6. レビュー後に設計の立て直しが必要なら、**別ターンで Sonnet 5 許可**を取り発想役に回す（レビューと混ぜない）。

## hook にしない理由

`stop` 毎回発火はタイムアウト・コスト爆発を招く。本スキルを Loop の Verifier 前後で明示呼び出しする。

## 関連

- モデル方針: `research-brain/wiki/ai-engineering/cursor_model_routing.md`
- 統合提案: `research-brain/inbox/agent_ops_proposals_2026-07-31/00_synthesis.md`
