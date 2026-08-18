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
| **runbook** | `demo-runbook.html` | OTP/qsub 当日オペ | チェックリスト・短文。`<pre>` コピーボタン＋`ul.check` は押せる（リロードで消える・保存なし） |
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
- runbook の `ul.check > li` はテンプレ JS が本物の checkbox にする（**永続化しない**。リロードで未チェックに戻るでよい）。
- スマホ／ntfy で開く成果物は **HTML のみ**（`.md` 直リンク禁止。`open-artifact` / `ntfy-notify` 参照）。

### 用語サイドバー（2026-08-07・全テーマ必須）

研究用の仮記号・非一般の HPC/実験用語を本文で使うときは次を守る。

1. **本文ではまず普通の日本語（または英単語そのまま）**。記号だけを前提にしない。長い場合のみ「送信待ちになっているジョブの件数（以後このページでは短い記号を使可）」のように一度定義する。
2. **用語説明はメイン中央に長く置かない**。
   - **横長（PC）**: sticky サイドバーに用語一覧を常時表示。本文の用語をホバーしたら **サイドバーの対応項目をハイライト**（本文付近のポップは出さないでよい）。
   - **狭い画面**: サイドバーは隠す。本文の用語をホバー／タップしたら、その語の **すぐ上または下に小さな説明（ツールチップ）** を出す。横からのドロワーは必須にしない。
3. サイドバー／ツールチップに載せる語の例: Ready, B0, B1, OBS_R1, O2a, M_p95, WIN/LOSE, background, flush, poll_interval, Stage G。一般語（ジョブ、待ち時間）は不要。
4. CSS はページ内に自己完結で足してよい（この規則のためテンプレ CSS への最小追加は許可）。

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
