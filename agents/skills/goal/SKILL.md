---
name: goal
description: >-
  /goal 相当。セッションの Goal・成功条件・制約・Next を1枚に固定してから作業する。
  「ゴール決め」「/goal」「目的を明確に」「HANDOFF 前に目標整理」で発動。
---

# goal

Antigravity 等の `/goal` に相当する薄い Cursor スキル。過剰なフレームワークは置かない。

## いつ使うか

- セッション開始・話題が大きく変わった直後
- Dual-track / 長作業のオーケストレーション開始時
- compact 後や HANDOFF 作成前

## 手順

1. ユーザー発話と `context/current_state.md`（research-brain）またはプロジェクト TODO を読む。
2. 次のテンプレを **チャットに出し、必要なら `inbox/GOAL_YYYY-MM-DD.md` に保存**する:

```markdown
# GOAL YYYY-MM-DD
- Goal: （1文。研究なら主張可能な問い／成果）
- Success: （機械 or 人間が判定できる条件）
- Constraints / Do NOT: （委託禁止・クラスタ・モデル許可）
- Verifier: （pytest / dry-run / 人間レビュー HTML 等）
- Out of scope: （やらないこと）
- Next 3: （具体アクション）
```

3. Success が曖昧なら作業を始めず、ユーザーに1問だけ確認する。
4. 層判定: Goal 固定は Context。自動反復は Loop（Verifier 必須）。マルチエージェント分岐はまだ Graph と呼ばない。

## モデル

整理自体は現行エージェントで可。長文の優先度議論だけ Grok / 許可時 Sonnet 5。

## 関連

- HANDOFF テンプレ: `research-brain/inbox/HANDOFF_*.md`
- Loop 最小定義: sandbox `docs/logs/goal_based_loop_min_2026-07-31.md`
- 設定変更時: `update-agent-config`
