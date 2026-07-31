---
name: human-review-html
description: >-
  人間レビュー用 HTML のトーン／テンプレを選んで複製する。
  「HTML作って」「open-artifact用」「MTG用ページ」「自分用の読みもの」「主張境界HTML」で発動。
  open-artifact の直前に使う。
---

# human-review-html

## 目的

毎回ゼロから CSS を作らず、**状況に合った自己完結 HTML** を低コストで出す。  
見本: `~/brain/research-brain/wiki/templates/human-review/`

## 選択表（迷ったらこれ）

| ID | ファイル | 使うとき | トーン |
|----|----------|----------|--------|
| **solo-deep** | `demo-solo-deep.html` | 自分用の腹落ち・概念整理 | 語りかけ可・図多め |
| **meeting-wide** | `demo-meeting-wide.html` | 指導・ラボ MTG・Zoom 共有 | 語りかけなし・用語集・横長密度 |
| **claim-lab** | `demo-claim-lab.html` | 論文前・Public 寄りの実験まとめ | 言ってよい/ダメ・再現・限界 |
| **runbook** | `demo-runbook.html` | OTP/qsub 当日オペ | チェックリスト・短文 |
| **scorecard** | `demo-scorecard.html` | 敵対レビュー結果の保存 | SCORE/Findings 固定 |

案内ハブ: `INDEX.html`

## 手順

1. 上表から ID を1つ選ぶ（混ぜない。必要ならページを分ける）。
2. デモ HTML を **コピー**して配置先へ（例: `wiki/.../YYYY-MM-DD-topic.html` または sandbox `docs/logs/`）。
3. 見出し・表・コマンド・主張だけ差し替える。**CSS は原則触らない**（トーン崩壊を防ぐ）。
4. HTML コメントの `TEMPLATE:` 行は残す。
5. 締めはスキル `open-artifact`（Mac オフラインなら URL のみ）。

## 制約

- **単一 HTML 自己完結**。React/Vite ビルドは使わない。
- CDN（フォント・Mermaid）は任意。オフラインでも本文が読めること。
- meeting / claim では「あなた」「僕」の語りかけを使わない。
- solo では語りかけ可。Zoom 前提の過密レイアウトは避ける。
- 紫グラデ単色・汎用ダッシュボード見た目に逃げない（既存デモの方向を踏襲）。

## 新しいテンプレを足すとき

1. `demo-*.html` を追加（題材は既存デモと同じ話でも可）。
2. `INDEX.html` のカードと表を更新。
3. 本スキルの選択表を更新。
4. 任意: `adversarial-review` でトーン分離と自己完結を確認。

## 関連

- `open-artifact` — 開く
- `goal` — 締めに HTML + open-artifact
- `adversarial-review` — 品質ゲート
- フォーマットガイド: `research-brain/.agents/references/wiki_formatting_guide.md`
