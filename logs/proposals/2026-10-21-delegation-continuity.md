# 提案: 委譲の「継続 / 新規 / steer」判定と委譲台帳

> 提案書。正本ではない。実装は `b141ce59`（agents ルール再編スレッド）が settle した後に、同スレッドから行う。
> 本書は別スレッド（`a74bd965`）で作成した。競合回避のため、このスレッドから `agents/` 配下は編集していない。

## 0. 背景（実測した事故）

`b141ce59` の bakeoff で Argon を3回起動した。うち1回は同一成果物の続きだったのに新規起票されている。

| 子スレッド | 起動 | clientRequestId | 判定 |
|---|---|---|---|
| Argon rules-plan validity review | 04:39 | （別） | 新規で正しい（独立レビュー） |
| Worker bakeoff task design（63 items） | 06:14 | `bakeoff-design-2026-10-21-v1` | 起点 |
| T2 spec clarification（9 items） | 06:25 | `bakeoff-t2-spec-clarify-2026-10-21-v1` | 誤り（design の続き） |

`clientRequestId` が別物＝`delegate_task` が2回呼ばれた証拠。同一ルーブリックの改訂を履歴なしの2体目に渡したため、設計意図の食い違い（採点基準のドリフト）リスクを負っていた。

## 1. 原因（3層）

1. **注入プロンプトとの衝突**: T3 は「childThreadId は*別のレビューラウンド*の宛先ではない」と書く。エージェントは「childThreadId に送ってはならない」と一般化して読める。
2. **ルールが非操作的**: 現行 `agents/rules/delegation.md` の「同じ作業の続きは `t3_thread_send`」は判定基準を持たない。"同じ作業" の境界がモデルごとに揺れる。
3. **ID の置き場が無い**: 親が 21 run / 415 item まで育つとコンパクションで `childThreadId` が消える。消えた状態では再起票が唯一の実行可能な選択肢になる。

## 2. 実測（2026-10-21, 無料モデルで1回）

`delegate_task` → `t3_thread_send(childThreadId)` の継続を、`opencode/deepseek-v4.1-flash-free`（inherit・$0）で検証した。

| 段階 | 呼び出し | 結果 |
|---|---|---|
| 1ターン目 | `delegate_task` | `taskId: node:...continuation-probe...v1` / summary `MINT-42` |
| 2ターン目 | `t3_thread_send(childThreadId)` | **同じ childThreadId**、`delivery: started`、**新しい taskId** が発行 |
| 2ターン目結果 | `task_status` | summary `MINT-42`（= 1ターン目の文脈を保持） |

確定した事実:

- 継続は機能する。`childThreadId` は安定キー。
- **`taskId` はターンごとに再発行される**（`thread-send` 由来の node ID）。台帳は `childThreadId` を主キーにし、`taskId` は追記する。
- 継続でも完了通知は親に届く。

## 3. 判定木（実装する中身）

```
次の作業は、子の内部状態を必要とするか？
  隠しテストの中身 / 却下した設計案 / ルーブリックの意図 / 子がディスクに作った途中成果物
    ├─ Yes → 独立した判断が本質か？（第二意見 / ブラインド評価 / Breaker 交代）
    │        ├─ No  → 【継続】t3_thread_send(childThreadId)
    │        └─ Yes → 設計ミス。役割を分ける（採点者=設計者で継続、独立検証者は別モデルで新規）
    └─ No  → 【新規】delegate_task（brief に前提・制約・完了条件を全部書く）
実行中に前提が変わった → 【steer】
```

要点: **ブラインドは「記憶を消す」ことではなく「候補を匿名化する」こと**。ルーブリック作者が採点するのは継続が正しい。

## 4. コストの向き（両方向に書く）

- 継続が得: 入力の再送・再読込が消える。追補が1〜2ターンで閉じる。対象成果物が同一。
- 新規が得: 子の履歴の大半が死荷重。往復が長引く見込み。独立性が本質。
- 中間: **新規＋蒸留 brief**（子の結論だけ渡す。生ログは渡さない）。
- 注意: high effort は毎ターン履歴全体を読み直すので、往復を長引かせると思考トークンが増える。「常に継続」は誤り。

原則: **成果物1つにつき子スレッド1本**。同じ成果物に対して `delegate_task` が2回出たら、それは設計の匂い。

## 5. 差し替え文面

### 5.1 `agents/rules/delegation.md`

現行の1行（「同じ作業の続きは `t3_thread_send(childThreadId)`。独立レビューは新規 `delegate_task`。実行中の訂正は `mode: "steer"`。」）を、次の小見出しに置き換える。

```markdown
### 追補・訂正・別ラウンドの使い分け

| 状況 | 手段 | 安定キー |
|---|---|---|
| 実行中に前提が変わった | `mode: "steer"` | 実行中の子 |
| 同一成果物の続き（仕様補足・却下理由の共有・採点） | `t3_thread_send(childThreadId)` | childThreadId |
| 独立した別ラウンド（第二意見・別成果物・Breaker 交代） | 新規 `delegate_task` | 新しい clientRequestId |

判定は2問。1問目が Yes で2問目が No なら継続、2問目が Yes なら新規。

1. 次の作業は子の内部状態（隠しテスト・却下案・ルーブリックの意図・途中成果物）を必要とするか。
2. 独立した判断が本質か（第二意見・ブラインド評価・Maker-Breaker の Breaker 交代）。

ブラインド性は候補の匿名化で作る。子の記憶を消して作らない。
1問目と2問目が両方 Yes になるのは設計ミス。役割を分ける。

T3 の「childThreadId は別のレビューラウンドの宛先ではない」は**独立ラウンドの禁止**であり、同一タスクの追補は `t3_thread_send(childThreadId)` が正規手段（実測済み）。
追補では `taskId` が新しく発行される。台帳の主キーは `childThreadId`、`taskId` はターンごとに追記する。
```

### 5.2 `agents/GLOBAL_RULES.md` の「2. 委譲」に1行追加

```markdown
- 子の追補は台帳の `childThreadId` に送る。台帳に無いときだけ新規起票する。
```

## 6. 委譲台帳（新規。衝突しない追加のみ）

`logs/delegations/<親スレッド短縮ID>.jsonl` に1行1追記。既存行は書き換えない。

```json
{"ts":"2026-10-21T06:14:38Z","childThreadId":"thread:...","taskId":"node:...","turn":1,"provider":"antigravity","model":"gemini-4-argon-high","purpose":"bakeoff task design","reqId":"bakeoff-design-2026-10-21-v1"}
{"ts":"2026-10-21T06:25:05Z","childThreadId":"thread:...","taskId":"node:...","turn":2,"purpose":"T2 spec clarification","reqId":"bakeoff-t2-spec-clarify-2026-10-21-v1"}
```

規律（2つだけ）:

1. `delegate_task` を呼ぶ前に台帳を読む。該当 `childThreadId` があれば継続を検討する。
2. 呼んだ直後に1行足す（`childThreadId`、`taskId`、モデル、目的、`reqId`）。

`clientRequestId` 規約: `<task>-<date>-vN`。同一論理タスクの再試行は同じ ID、新しいラウンドは新しい ID。二重起票は ID で機械検出できる。

## 7. 併せて提案: ファイル所有権

今回の作業で判明した別の問題。同じ worktree を2スレッドが同時に使うと、`git add -A` で相手の作業中データ（`scratch/bakeoff/` 等）を巻き込む。

```markdown
- 同じリポジトリで別スレッドが稼働中なら、そのスレッドが触っているファイルを編集しない。
- `git add -A` を使わない。パスを明示して stage する。
- commit は相手スレッドが terminal になってから。
- worktree 分離はルール共有を切らない（`AGENTS.md` が symlink で本体を読むため）。
```

## 8. 実装手順（`b141ce59` 側で実行）

1. この提案を読み、5.1 / 5.2 / 7 を適用する。
2. `logs/delegations/` を作り、台帳の書式を 6 のとおり決める（空でよい）。
3. 検証: `logs/agents-rules-refactor-plan-2026-10-21.md` の「検証コマンド」2本（禁止記法・リンク切れ）が無出力であること。
4. 検証: 追加した文面に、セクション番号参照・ホスト絶対パス・`file` スキームの URL が含まれないこと。
5. `git add` はパス明示。commit は1つにまとめる（例: `docs(agents): define delegation continuation rules`）。

## 9. 未決事項

- 台帳を人間が読む頻度が低いなら、jsonl ではなく Markdown 表にする選択肢もある。
- 台帳の肥大化（1親スレッドで10件超）時のローテーションは未定義。
- 継続の往復上限（1〜2ターン）は経験則。実測で裏づけるなら task ごとのトークン集計が要る。
