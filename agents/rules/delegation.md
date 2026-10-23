# 委譲（T3 / Antigravity / CLI）

## 1. 委譲の目的

- 親エージェントのコンテキスト汚染（大量の打鍵・ログ・ツール実行による Context Rot）を防ぐ。
- 司令塔（Commander）と作業役（Worker）の関心事を厳密に分離する。

## 2. インライン引き受けの禁止

- サブエージェント起動や委譲がエラー（`PlatformClient is nil` 等）で失敗しても、親が「失敗したから親が直接やる」とインラインで引き受けてはならない。
- 親が引き受けると、意図したコンテキスト分離・役割分担がすべて破綻する。

## 3. T3 Code（`delegate_task`）

**用途**: 親と異なるモデル（例: Gemini 4 Argon）への委譲、クロスプロバイダ委譲、T3 ネイティブ子タスク起票。

**呼び出し例**:

```json
{
  "target": { "providerInstanceId": "antigravity", "model": "gemini-4-argon-medium" },
  "mode": "wait",
  "role": "design",
  "task": "..."
}
```

- 同一モデルでよい場合は `{ "providerInstanceId": "opencode", "model": "opencode/deepseek-v4.1-flash-free" }` を指定し、options を空にする（inherit 相当）。
- T3 側のライブカタログ（`orchestrator_capabilities`）を参照して、独立した子スレッドを起票する。
- 子は親の会話履歴を引き継がない。brief に前提・制約・完了条件を全部書く。
- `target` は **(provider, model) の組**で選ぶ。モデル名がカタログにあっても、契約が違うプロバイダでは選ばない（固定表は `docs/routing.md` §4。例: Argon は `antigravity` のみ、cursor に `gemini-4-argon` が出ても選ばない）。
- 同一モデルの軽い並列なら native `subagent` でもよい（T3 の子スレッドは作られない）。

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

## 4. Antigravity（`invoke_subagent`）

**用途**: 親と同じモデルでの軽量・高速並行処理。

- 必ず `Model: "inherit"` を指定する。
- `Model: "flash"` / `"pro"` などの明示文字列は、ローカル ACP ハーネスの `PlatformClient is nil` でクラッシュする。`inherit` なら名前解決をスキップして親構成を複製できる（異モデルへの変更は不可）。

## 5. 外部 CLI フォールバック

プラットフォーム内蔵の委譲が使えない場合、またはターミナルから直叩きする場合は、Bash 経由で外部 CLI を別プロセス起動する。

- 打鍵・スキャフォールディング・探索（Google AI Pro 枠）: `agy --dangerously-skip-permissions --model gemini-3.8-flash-high --print "..." < /dev/null`
- コーディング・実装・テスト修正（Cursor Pro）: `cursor-agent -p --yolo --model composer-2.5 "..." < /dev/null`
- 超高度設計・数理仕様化・敵対監査（Argon 週枠）: `agy --dangerously-skip-permissions --model gemini-4-argon-medium --print "..." < /dev/null`
- **DeepSeek 従量 API を Worker に使う**: `dsh-sub --repo <dir> --prompt "..."`（既定 `deepseek-flash` / effort `high`）。フラグ・出力JSON・exit code・権限はスキル `deepseek-harness` が正本。使う条件と予算は `rules/models.md` §2.5。

effort は既定 **medium**。high は「成功条件が開いている」案件（何が良いか自体を決める）だけに使い、呼ぶ前に1行で理由を書く。

**非対話呼び出しの罠（2026-10-21 実測）。忘れると20分溶ける。**

- **`</dev/null` を必ず付ける**。`opencode run` は常駐サービスと協調するため、stdin を開いたままだと入力待ちでブロックする。
- **`agy` はフラグの順序に注意**。`agy -p --dangerously-skip-permissions ...` と書くと、`-p` が後続のフラグをプロンプト文字列として食い、`code 2` で落ちる。`--dangerously-skip-permissions --print "..."` の順にする（または `-p="..."`）。
- **YOLO フラグはツールごとに違う**: opencode は `run --auto`、cursor-agent は `-p --yolo`、agy は `--dangerously-skip-permissions`。
- **OpenCode の思考抑制**は `-m "deepseek/deepseek-flash#none"`（`#low` / `#high` / `#max`）。整形・分類・抽出のような機械的作業で使う。

## 6. モデル同一性（Strict Model Fidelity）

- 最初に指定・意図されたモデルと完全に同一のモデルを CLI 引数に指定する。
- 勝手に別モデルへ昇格・降格しない。
  - `flash` 指定 → `agy --model gemini-3.8-flash-high`
  - `composer` 指定 → `cursor-agent --model composer-2.5`
  - `argon` 指定 → `agy --model gemini-4-argon-medium`（high は明示指示があるときだけ `-high`）
- 指定モデルの枠（クォータ・コスト）を厳守する。

## 7. 親の振る舞い

- 子の完了ステータス、成果物のコミットハッシュ、要約だけを親コンテキストに戻す。中間ログは持ち込まない。

## 8. チャネルの目安

優先の目安であり、Cursor Task による実装を全面禁止しない。

1. **実装・多段（編集→pytest→修正）**: T3 `delegate_task`（別スレッド）または Cursor Task。
2. **敵対レビュー・視点提案・採点（read-only・短時間・戻り値で足りる）**: `delegate_task`（Argon / Claude 等）または CLI（`agy`）。`pi` は使わない。
3. **コンテキスト分離**: 別 BRIEF は `/clear` または別スレッド。モデル切替は `/model`。
4. **モデル名を先頭に（可視性）**: Cursor Task の `description` は `{通称} {短い作業}`（例: `Fable open-artifact audit`）。UI の「Running N agents…」に出る。通称は人が呼ぶ名前だけ（Grok / Fable / Composer / Gemini Pro / Gemini Flash）。版数・slug は書かない。inherit なら親と同じ。agy / CLI は呼ぶ直前にチャットへ `{通称} を呼び出します` を1行。
5. **Cursor を `delegate_task` で呼ぶとき**: `target.options` に `{"fastMode": false}` を必ず明示し、応答の `options` で確認する。未指定は Fast で動く（2026-10-23 実測。T3 の UI は Fast オフと表示するが信用しない）。`rules/models.md` §2。
   - **既存スレッドへの追補**: スレッドは作成時の設定を引き継ぐ。options が無い旧スレッドは、追補の前に `t3_thread_configure`（`modelSelection.options` に `fastMode: false` と effort）で直し、`t3_thread_configuration` で確認してから `t3_thread_send` する。「新規起票して brief を付け直す」で回避しない（子の文脈が失われる）。
   - CLI（`cursor-agent`）は既定が非 Fast（`~/.cursor/cli-config.json` の `fast: false`）なので、ガードで遮断はしない。`-fast` 付き ID を自分で選ばないこと。問題は T3 経由の `delegate_task` だけ。

## 9. 敵対レビューのスコープ

1. **正本に無い使用上限を発明しない**（例: Fable 1日1回、別 BRIEF の別日必須、案Aと案Bの同日禁止）。
2. **「同日同問」は Fable↔Opus（または同役二重）に限定**。Fable の別 BRIEF・別セッションでの同日 A→B は禁止理由にしない。
3. 疑わしい制限指摘は severity を `major` にせず `nit` とし、正本の該当行を引用必須。引用できなければ指摘しない。

## 10. ファイル所有権

同じリポジトリで別スレッドが稼働中なら、そのスレッドが触っているファイルを編集しない。

- `git add -A` を使わない。パスを明示して stage する（相手の `scratch/` 等を巻き込まない）。
- commit は相手スレッドが terminal になってから。
- worktree 分離はルール共有を切らない（`AGENTS.md` が symlink で本体を読むため）。

## 11. MCP（Linear 等）

外部 MCP を繋ぐときは、**読み取りは自由・書き込みは明示指示があるときだけ**にする。

- 起票・更新・クローズ・コメント投稿は「指示された1操作」に限る。まとめて作らない。
- 接続設定（`opencode mcp add` / `claude mcp add`）は `~/.config/opencode/opencode.jsonc` 等に入る。**T3 稼働中に T3 側の設定を書き換えない**。
