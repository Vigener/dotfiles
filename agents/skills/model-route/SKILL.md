---
name: model-route
description: "タスク内容や質問に応じて、最適な AI モデル（Opus / Codex / codex-sub / dsh-sub / Flash / Grok 等）の選定・ルーティング、Thinking レベルを即答判定する。「should we use argon?」「これOpus使うべき？」「どのモデルで回すべき？」「モデルルーティング」「モデル判定」「model route」で発動。"
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
   → Yes なら **Opus 5.5**（`models.md` §3.6 **要申請**。ループ頭設計と別）または Sonnet 5.5 (medium)（名指し時）。Argon は設計に使わない。
3. **Task**: Design / Implement / Extract のどれか。
   - Design（大きなループ）: 頭 1 回 **Opus 5.5**（方向・DoD）→ 細部 **Codex（`codex-sub`）**。
   - Implement（W1）: ローカルは **`codex-sub`**（Private は Composer。無ければ `dsh-sub`）。
   - Extract / W2 / 整形: **Gemini 3.8 Flash**。
   - 敵対レビュー: **T1/T2/T3 なし**。Breaker は**ループ末 Opus 5.5** のみ（§3.6 申請不要）。
3.5. **Visual**: 成果物の合否は見た目で決まるか。
    → Yes なら W1 は `codex-sub` のまま、目視 QA は **Gemini 3.8 Flash** → フォールバック **Grok 4.7**（Cursor・非 Fast。PNG 能力は未確認）。2 回目は **Opus 5.5 引き上げ**（`routing.md` §3 Visual QA）。
4. **Flag**:
   - Private → **Composer 2.5**（Cursor・非 Fast）。**Codex に出さない**。
   - Search → **Gemini 3.8 Flash**。
   - Orchestration → **Opus 5.5**（Team）。Opus が使えないときのみ **Grok 4.7 代行**（`models.md` §2.1）。
   - 人が読む日本語推敲 → **yomiyasu（本体） + Gemini 3.8 Flash**（2026-10-30 決定。ログ要約とは別）。
5. **Grok 4.7（ローカル）**: **Visual QA フォールバック**または **Opus 不在時の司令塔代行**のみ。Fast は使わない（`docs/routing.md` §8）。
6. **環境指定**: `in agy` / `in claude` / `codex-sub` / `dsh-sub` / `in cursor`（例外のみ）。
   省略時は `routing.md` §4 のフォールバック順。
7. **昇格**: 前提崩れ・同指摘 2 回 → **Opus 5.5**（`models.md` §3.6 **申請不要**）。回数と理由を記録（RES-23）。

**やらないこと**: 残量ペースでモデルを動的に切り替える（旧手順 5 を廃止）。必要なら `update-ai-usage` で使い切り防止のみ確認する。

## 出力フォーマット

```markdown
### 🎯 モデル選定判定
- **推奨モデル**: `codex-sub`（W1） / `claude: Opus 5.5`（オーケストレーター） 等
- **effort**: medium（Codex W1・`codex-sub` 既定。ループ頭/末 Opus は `models.md` §3.6 申請不要）
- **判定理由**: [Task / Flag と根拠を1〜2文]
- **推奨アクション**: [次にどう指示するか]
- **記録**: RES-23 中は Codex 残・Codex タスク・Opus 差戻・Claude Team 残量等（`logs/res23/README.md`）
```

## 禁止

- 参照ファイルに無いモデル・数値・slug を発明しない。
- 残量を推測で書かない。必要なら `update-ai-usage` を実行する（ペース判定には使わない）。
- 指定モデルを勝手に昇格・降格しない（Strict Model Fidelity）。
- ローカル W1 に Flash / Composer を割り当てない（Private / Cloud を除く）。
- **API キーの Codex** / **Private への Codex**。
- Argon を設計・仕様に割り当てない（発想のみ）。
- Gemini 3.8 Flash を敵対レビューに割り当てない。
- Maker が Codex のあいだ **Sonnet / `dsh-sub` を Breaker にしない**（ループ末 Opus のみ）。
