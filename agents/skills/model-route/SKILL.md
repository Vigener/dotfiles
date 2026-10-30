---
name: model-route
description: "タスク内容や質問に応じて、最適な AI モデル（Opus / Sonnet / dsh-sub / Flash / Grok 等）の選定・ルーティング、Thinking レベルを即答判定する。「should we use argon?」「これOpus使うべき？」「どのモデルで回すべき？」「モデルルーティング」「モデル判定」「model route」で発動。"
---

# `model-route`

タスクに最適なモデル・実行環境・思考深度を即答する**手順書**。
モデルの事実は持たない。方針は `rules/models.md`、対応表は `docs/routing.md` を読む。

## 参照（この順で読む）

1. `~/dotfiles/agents/rules/models.md` — 方針・禁止・優先順位
2. `~/dotfiles/agents/docs/routing.md` — タスク別の対応表・昇格/降格

## 判定手順

1. **環境**: Cursor **Cloud Agent** かローカルか。
   - Cloud → 設計 **Grok 4.7**、実装 **Composer 2.5**（いずれも非 Fast）。`routing.md` §3 Cloud Agent。
2. **Phase-First**: 教員報告前・数理難所・章立て・仕様策定の山場か？
   → Yes なら **Opus 5.5**（`models.md` §3.6 **要申請**。ループ頭設計と別）または Sonnet 5.5 (medium)。Argon は設計に使わない。
3. **Task**: Design / Implement / Extract のどれか。
   - Design（大きなループ）: 頭 1 回 **Opus 5.5**（方向・DoD）→ 細部 **Sonnet 5.5 (medium)**。
   - Implement（W1）: ローカルは **`dsh-sub`** のみ（Private は Composer）。
   - Extract / W2 / 整形: **Gemini 3.8 Flash**。
   - 敵対レビュー: **T1** `dsh-sub`（**W1 直後は Sonnet 5.5 (medium)**）/ **T2–T3** Sonnet 5.5 (medium) / ループ末 Opus 5.5。
3.5. **Visual**: 成果物の合否は見た目で決まるか。
    → Yes なら W1 は `dsh-sub` のまま、目視 QA は **Gemini 3.8 Flash** → フォールバック **Grok 4.7**（Cursor・非 Fast。PNG 能力は未確認）。2 回目は **Opus 5.5 引き上げ**（`routing.md` §3 Visual QA）。
4. **Flag**:
   - Private → **Composer 2.5**（Cursor・非 Fast）。
   - Search → **Gemini 3.8 Flash**。
   - Orchestration → **Opus 5.5**（Team）。Opus が使えないときのみ **Grok 4.7 代行**（`models.md` §2.1）。
   - 人が読む日本語推敲 → **yomiyasu + Gemini 3.8 Flash**（RES-24 試行中。ログ要約とは別）。
5. **Grok 4.7（ローカル）**: **Visual QA フォールバック**または **Opus 不在時の司令塔代行**のみ。Fast は使わない（`docs/routing.md` §8）。
6. **環境指定**: `in agy` / `in claude` / `dsh-sub` / `in cursor`（例外のみ）。
   省略時は `routing.md` §4 のフォールバック順。
7. **昇格**: 前提崩れ・同指摘 2 回 → **Opus 5.5**（`models.md` §3.6 **申請不要**）。回数と理由を記録（RES-23）。

**やらないこと**: 残量ペースでモデルを動的に切り替える（旧手順 5 を廃止）。必要なら `update-ai-usage` で使い切り防止のみ確認する。

## 出力フォーマット

```markdown
### 🎯 モデル選定判定
- **推奨モデル**: `dsh-sub`（W1） / `claude: Opus 5.5`（オーケストレーター） 等
- **effort**: medium（W1 `dsh-sub` は high 既定。high は「成功条件が開いている」案件。ループ頭/末 Opus は `models.md` §3.6 申請不要）
- **判定理由**: [Task / Flag と根拠を1〜2文]
- **推奨アクション**: [次にどう指示するか]
- **記録**: RES-23 中は Opus 昇格・`dsh-sub`・Claude Team 残量を残す
```

## 禁止

- 参照ファイルに無いモデル・数値・slug を発明しない。
- 残量を推測で書かない。必要なら `update-ai-usage` を実行する（ペース判定には使わない）。
- 指定モデルを勝手に昇格・降格しない（Strict Model Fidelity）。
- ローカル W1 に Flash / Composer を割り当てない（Private / Cloud を除く）。
- Argon を設計・仕様に割り当てない（発想のみ）。
- Gemini 3.8 Flash を敵対レビューに割り当てない。
