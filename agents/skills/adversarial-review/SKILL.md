---
name: adversarial-review
description: >-
  Cursor auto-review の代わりに agy/pi で敵対レビューする。
  「レビューして」「敵対レビュー」「agyで見て」「差分レビュー」で発動。
  hook には載せない（コスト爆発防止）。
---

# adversarial-review

## 原則

- **read-only**: レビュアーに編集させない
- **diff 優先**: 全文は T3 のみ
- **トリガー駆動**: 毎ターン回さない
- **agy Opus 禁止**（Google AI Pro が即 5h limit）。高品質が要るならユーザーに **Sonnet 5 許可**を求める

## ティア

| ティア | いつ | 渡すもの | モデル例 |
|---|---|---|---|
| T1 | コミット前・軽い草案 | `git diff` のみ | `pi --model opencode-go/kimi-k3` または `agy --model gemini-3.6-flash-high` |
| T2 | 主張・設計判断・status 更新 | diff + 関連1–2ファイル | `agy --model gemini-3.1-pro-high` または `agy --model claude-sonnet-4-6` |
| T3 | T2 で major+、または節目 | 広め | **許可時** Cursor Sonnet 5。未許可なら Sonnet 4.6（agy）で止める |

## 手順

1. ティアを決める（迷ったら T1）。
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

4. triage: blocker/major だけ修正。nit は溜めて無視可。
5. 結果を `inbox/REVIEWS/` または sandbox `docs/logs/` に残す（任意）。

## hook にしない理由

`stop` 毎回発火はタイムアウト・コスト爆発を招く。本スキルを Loop の Verifier 前後で明示呼び出しする。

## 関連

- モデル方針: `research-brain/wiki/ai-engineering/cursor_model_routing.md`
- 統合提案: `research-brain/inbox/agent_ops_proposals_2026-07-31/00_synthesis.md`
