---
name: model-route
description: "タスク内容や質問に応じて、最適な AI モデル（Argon / Opus / Sonnet / Composer / Flash / Grok 等）の選定・ルーティング、コスト階層、Thinking レベルを即答判定する。「should we use argon?」「これArgon使うべき？」「これOpus使うべき？」「どのモデルで回すべき？」「モデルルーティング」「モデル判定」「model route」で発動。"
---

# `model-route`

タスクに最適なモデル・実行環境・思考深度を即答する**手順書**。
モデルの事実は持たない。方針は `rules/models.md`、対応表は `docs/routing.md` を読む。

## 参照（この順で読む）

1. `~/dotfiles/agents/rules/models.md` — 方針・禁止・優先順位
2. `~/dotfiles/agents/docs/routing.md` — タスク別の対応表・昇格/降格

## 判定手順

1. **Phase-First**: 教員報告前・数理難所・章立て・仕様策定の山場か？
   → Yes なら最高峰（Argon / Opus 5.5 / Sonnet 5.5）を残量ペース無視で投入。
2. **Task**: Design / Implement / Extract のどれか。
3. **Flag**: Private / Search / Orchestration のどれか。
4. **環境**: `in agy` / `in cursor` / `in claude` / `api` の指定があるか。
   省略時は `routing.md` のフォールバック順（agy → Cursor → Claude Team）。
5. **コスト階層**: 低 / 中 / 高 を判定し、現在の残量と照合する。
   残量は `~/dotfiles/bin/update-ai-usage --format markdown --no-notify --no-write-runcat` で取得。

## 出力フォーマット

```markdown
### 🎯 モデル選定判定
- **推奨モデル**: `agy: Gemini 4 Argon (medium)`
- **effort**: medium（high は「成功条件が開いている」案件だけ。`rules/models.md` 3.5）
- **コスト階層**: 中（残量は `update-ai-usage` で確認。サブスク枠も 3.6 のゲート対象）
- **判定理由**: [Task / Flag と根拠を1〜2文]
- **推奨アクション**: [次にどう指示するか]
```

## 禁止

- 参照ファイルに無いモデル・数値・slug を発明しない。
- 残量を推測で書かない。必要なら `update-ai-usage` を実行する。
- 指定モデルを勝手に昇格・降格しない（Strict Model Fidelity）。
