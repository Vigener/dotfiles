# 委譲台帳（`logs/delegations/`）

子スレッドの ID はコンパクションで消える。消えた状態で「続きを頼む」と、再起票しか選べなくなる。
台帳はその目次であり、**追記専用**（既存行は書き換えない）。

## 形式

1ファイル = 1親スレッド。`<親スレッド短縮ID>.jsonl`、1行1イベント。

```json
{"ts":"2026-10-21T06:14:38Z","childThreadId":"thread:...","taskId":"node:...","turn":1,"provider":"antigravity","model":"gemini-4-argon-medium","purpose":"bakeoff task design","reqId":"bakeoff-design-2026-10-21-v1"}
```

| フィールド | 内容 |
|---|---|
| `ts` | UTC。ISO 8601 |
| `childThreadId` | **主キー**。継続はこの ID に `t3_thread_send` |
| `taskId` | ターンごとに再発行される。追記のみ |
| `turn` | 同じ子への何ターン目か |
| `provider` / `model` | 実際に指定した値（通称ではなく slug） |
| `purpose` | 何を頼んだか（1行） |
| `reqId` | `clientRequestId`。`<task>-<date>-vN` |

## 規律（2つだけ）

1. `delegate_task` を呼ぶ前に台帳を読む。該当 `childThreadId` があれば継続を検討する（判定は `rules/delegation.md` §3）。
2. 呼んだ直後に1行足す。

同一論理タスクの再試行は同じ `reqId`、新しいラウンドは新しい `reqId`。二重起票は ID で機械検出できる。

## 未決

- 1親スレッドで10件を超えたときのローテーションは未定義。
- 人間が読む頻度が低いなら Markdown 表にする選択肢もある（現状は jsonl を正とする）。
