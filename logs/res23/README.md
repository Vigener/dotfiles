# RES-23 計測ログ（追記専用）

Linear RES-23（〜2026-11-07）。**数値の目標は書かない。** 規範は `agents/rules/models.md` §0。

## 毎晩1行（手動またはスクリプト）

```text
YYYY-MM-DD | Codex残 | Codexタスク数、Opus差戻 | Claude Team残 |
Cursor残 | Gemini残 | DeepSeek USD
```

Claude / Cursor / Gemini / DeepSeek は:

```sh
~/dotfiles/bin/update-ai-usage --format markdown --no-notify --no-write-runcat
```

Codex 残量はこの変更では自動取得しない（ダッシュボードまたは対話 `/status` の写し）。

## `tasks.jsonl`（委譲のたびに1行追記）

| フィールド | 意味 |
| --- | --- |
| `ts` | ISO8601 |
| `provider` | `codex` または `dsh-sub` 等 |
| `model` | 実行後に分かったモデル名（不明なら空） |
| `purpose` | 短い目的 |
| `fallback_reason` | dsh-sub に落ちた理由（無ければ空） |
| `opus_reject` | `0` または `1` |
| `opus_reject_reason` | 差戻理由（無ければ空） |

夜に行数を数え、上記の1行に集約する。
