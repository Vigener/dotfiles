# 委譲（T3 / Antigravity / CLI）

## 1. 委譲の目的

- 親エージェントのコンテキスト汚染（大量の打鍵・ログ・ツール実行による Context Rot）を防ぐ。
- 司令塔（Commander）と作業役（Worker）の関心事を厳密に分離する。

## 2. インライン引き受けの禁止

- サブエージェント起動や委譲がエラー（`PlatformClient is nil` 等）で失敗しても、親が「失敗したから親が直接やる」とインラインで引き受けてはならない。
- 親が引き受けると、意図したコンテキスト分離・役割分担がすべて破綻する。

## 3. T3 Code: `delegate_task`

**用途**: 親と異なるモデル（例: Gemini 4 Argon）への委譲、クロスプロバイダ委譲、T3 ネイティブ子タスク起票。

**呼び出し例**:

```json
{
  "target": { "providerInstanceId": "antigravity", "model": "gemini-4-argon-high" },
  "mode": "wait",
  "role": "design",
  "task": "..."
}
```

- 同一モデルでよい場合は `{ "providerInstanceId": "opencode", "model": "opencode/deepseek-v4.1-flash-free" }` を指定し、options を空にする（inherit 相当）。
- T3 側のライブカタログ（`orchestrator_capabilities`）を参照して、独立した子スレッドを起票する。
- 子は親の会話履歴を引き継がない。brief に前提・制約・完了条件を全部書く。
- 同じ作業の続きは `t3_thread_send(childThreadId)`。独立レビューは新規 `delegate_task`。実行中の訂正は `mode: "steer"`。

## 4. Antigravity: `invoke_subagent`

**用途**: 親と同じモデルでの軽量・高速並行処理。

- 必ず `Model: "inherit"` を指定する。
- `Model: "flash"` / `"pro"` などの明示文字列は、ローカル ACP ハーネスの `PlatformClient is nil` でクラッシュする。`inherit` なら名前解決をスキップして親構成を複製できる（異モデルへの変更は不可）。

## 5. 外部 CLI フォールバック

プラットフォーム内蔵の委譲が使えない場合、またはターミナルから直叩きする場合は、Bash 経由で外部 CLI を別プロセス起動する。

- 打鍵・スキャフォールディング・探索（Google AI Pro 枠）: `agy --model gemini-3.8-flash-high --dangerously-skip-permissions -p "..."`
- コーディング・実装・テスト修正（Cursor Pro）: `cursor-agent --model composer-2.5 "..."` または `--model grok`
- 超高度設計・数理仕様化・敵対監査（Argon 週枠）: `agy --model gemini-4-argon-high --dangerously-skip-permissions -p "..."`

## 6. モデル同一性（Strict Model Fidelity）

- 最初に指定・意図されたモデルと完全に同一のモデルを CLI 引数に指定する。
- 勝手に別モデルへ昇格・降格しない。
  - `flash` 指定 → `agy --model gemini-3.8-flash-high`
  - `composer` 指定 → `cursor-agent --model composer-2.5`
  - `argon` 指定 → `agy --model gemini-4-argon-high`
- 指定モデルの枠（クォータ・コスト）を 100% 守る。

## 7. 親の振る舞い

- 子の完了ステータス、成果物のコミットハッシュ、要約だけを親コンテキストに戻す。中間ログは持ち込まない。

## 8. チャネルの目安

優先の目安であり、Cursor Task による実装を全面禁止しない。

1. **実装・多段（編集→pytest→修正）**: T3 `delegate_task`（別スレッド）または Cursor Task。herdr は主経路にしない。
2. **敵対レビュー・視点提案・採点（read-only・短時間・戻り値で足りる）**: `delegate_task`（Argon / Claude 等）または CLI（`agy`）。`pi` は使わない。
3. **コンテキスト分離**: 別 BRIEF は `/clear` または別スレッド。モデル切替は `/model`。
4. **モデル名を先頭に（可視性）**: Cursor Task の `description` は `{通称} {短い作業}`（例: `Fable open-artifact audit`）。UI の「Running N agents…」に出る。通称は人が呼ぶ名前だけ（Grok / Fable / Composer / Sol / Terra / Luna / Gemini Pro / Gemini Flash）。版数・slug は書かない。inherit なら親と同じ。agy / CLI は呼ぶ直前にチャットへ `{通称} を呼び出します` を1行。

## 9. 敵対レビューのスコープ

1. **正本に無い使用上限を発明しない**（例: Fable 1日1回、別 BRIEF の別日必須、案Aと案Bの同日禁止）。
2. **「同日同問」は Fable↔Sol（または同役二重）に限定**。Fable の別 BRIEF・別セッションでの同日 A→B は禁止理由にしない。
3. 疑わしい制限指摘は severity を `major` にせず `nit` とし、正本の該当行を引用必須。引用できなければ指摘しない。
