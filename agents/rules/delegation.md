# 委譲（T3 / Antigravity / CLI）

## 1. 委譲の目的

- 親エージェントのコンテキスト汚染（大量の打鍵・ログ・ツール実行による
  Context Rot）を防ぐ。
- 司令塔（Commander）と作業役（Worker）の関心事を厳密に分離する。
- **オーケストレーターのハンドオフ**: 司令塔（Opus）が `docs/routing.md` に
  従い Worker（W1 `codex-sub` 等）・探索・レビュアへ `delegate_task` / CLI で
  委譲するのは**本人が許可済み**。DeepSeek API は `rules/models.md` §2.5 の
  利用条件を満たす場合だけ。許可済み範囲の委譲は都度のユーザー申請は不要
  （Opus の追加用途は `rules/models.md` §3.6）。

## 2. インライン引き受けの禁止

- サブエージェント起動や委譲がエラー（`PlatformClient is nil` 等）で
  失敗しても、親が「失敗したから親が直接やる」とインラインで引き受けては
  ならない。
- 親が引き受けると、意図したコンテキスト分離・役割分担がすべて破綻する。

## 3. T3 Code（`delegate_task`）

**用途**: 親と異なるモデルへの委譲、クロスプロバイダ委譲、T3 ネイティブ子タスク起票。

- 呼び出し前に `orchestrator_capabilities` で利用可能性を確認する。
  同一モデルの委譲でも、実際の provider・model・options をライブカタログで
  選ぶ。存在しない設定やモデル slug を推測・発明しない。DeepSeek Free は
  使わない（`rules/models.md` §2.5）。
- 実行環境のツール契約を優先し、子 run の `next` 指示に従う。ポーリング
  （`task_status` や sleep のループ）は行わない。
- 子は親の会話履歴を引き継がない。brief に前提・制約・完了条件を全部書く。
- `target` は **(provider, model) の組**で選ぶ。モデル名がカタログにあっても、
  契約が違うプロバイダでは選ばない（固定表は `docs/routing.md` §4。
  例: Argon / Hydrogen は通常 `antigravity`、Google API 経路は
  `rules/models.md` §0.5、cursor に `gemini-4-argon` や `gemini-4-carbon` や
  `gemini-4-hydrogen` が出ても選ばない。`antigravity` の
  `gemini-4-hydrogen` は既定 `thinking_level` が `high` のため、必ず
  `options` に `{"thinking_level": "medium"}`（軽作業は `"low"`）を明示する。
  使い分けはスキル `model-route`、事実は `rules/models.md` §1.1–§1.2）。
- 同一モデルの軽い並列なら native `subagent`（Antigravity の `invoke_subagent`）
  でもよい（T3 の子スレッドは作られない）。

### 追補・訂正・別ラウンドの使い分け

| 状況 | 手段 | 安定キー |
| --- | --- | --- |
| 実行中に前提が変わった | `mode: "steer"` | 実行中の子 |
| 同一成果物の続き（仕様補足・却下理由の共有・採点） | `t3_thread_send(childThreadId)` | childThreadId |
| 独立した別ラウンド（第二意見・別成果物・Breaker 交代） | 新規 `delegate_task` | 新しい clientRequestId |

判定は2問。1問目が Yes で2問目が No なら継続、2問目が Yes なら新規。

1. 次の作業は子の内部状態（隠しテスト・却下案・ルーブリックの意図・途中成果物）を
   必要とするか。
2. 独立した判断が本質か（第二意見・ブラインド評価・Maker-Breaker の
   Breaker 交代）。

独立レビューや再実行・第二意見は、既存スレッドへの追補ではなく新規の
`delegate_task` で起票する。同一成果物の軽微な修正指示や追補のみ
`t3_thread_send(childThreadId)` を用いる。ブラインド性は候補の匿名化で作る。
子の記憶を消して作らない。1問目と2問目が両方 Yes になるのは設計ミス。
役割を分ける。

追補では `taskId` が新しく発行される。台帳の主キーは `childThreadId`、
`taskId` はターンごとに追記する。

## 4. Antigravity（`invoke_subagent`）

**用途**: 親と同じモデルでの軽量・高速並行処理。

- 必ず `Model: "inherit"` を指定する。
- `Model: "flash"` / `"pro"` などの明示文字列は、ローカル ACP ハーネスの
  `PlatformClient is nil` でクラッシュする。`inherit` なら名前解決をスキップして
  親構成を複製できる（異モデルへの変更は不可）。

## 5. 外部 CLI フォールバック

プラットフォーム内蔵の委譲が使えない場合、またはターミナルから直叩きする場合は、

Bash 経由で外部 CLI を別プロセス起動する。

モデルの選定・用途・制約は `rules/models.md` および `docs/routing.md` を
参照する（割当表は複製しない）。

- **CLI 実行の基本手段**:
  - `codex-sub --repo <dir> --prompt "..."`: ChatGPT Plus ログイン枠の
    Codex 呼び出し（effort 既定 medium）。未ログイン・利用上限・エラー時は
    停止し、API への自動切替は行わない。スキル `codex-harness`。
  - `dsh-sub --repo <dir> --prompt "..."`: DeepSeek API 呼び出し
    （`rules/models.md` §2.5 の利用条件を満たす場合のみ直接呼ぶ）。
    スキル `deepseek-harness`。
  - `agy --dangerously-skip-permissions --model <model-id> --print "..." < /dev/null`:
    Google AI Pro / Antigravity 枠（Hydrogen, Argon 等）。
  - `bin/gemini-sub`, `bin/hydrogen-sub`, `bin/carbon-sub`, `bin/argon-sub`,
    `bin/flash-sub`: Google Developer API 経路（既定 `medium`。
    `~/.config/gemini-sub/.env` は Prepay / オートチャージ OFF 確認済み、
    `rules/models.md` §0.5）。
  - `cursor-agent -p --yolo --model <model-id> "..." < /dev/null`:
    Cursor Pro 枠（Private 時の非 Fast Composer 等）。
  - `claude -p`: Claude Team 枠（Opus 等）。
- effort は既定 **medium**。high（Hydrogen は xhigh 可）は「成功条件が開いている」
  案件だけに使い、Google API（`gemini-sub` 系）は理由を 1 行記録して事後報告可、
  `agy` / Codex 等は事前申請に従う（無意味な引き上げは禁止、`rules/models.md` §0.5・§3.6）。

**非対話呼び出しの罠（2026-10-21 実測）。忘れると20分溶ける。**

- **`</dev/null` を必ず付ける**。`opencode run` は常駐サービスと協調するため、
  stdin を開いたままだと入力待ちでブロックする。
- **`agy` はフラグの順序に注意**。`agy -p --dangerously-skip-permissions ...`
  と書くと、`-p` が後続のフラグをプロンプト文字列として食い、`code 2` で
  落ちる。`--dangerously-skip-permissions --print "..."` の順にする
  （または `-p="..."`）。
- **YOLO フラグはツールごとに違う**: opencode は `run --auto`、
  cursor-agent は `-p --yolo`、agy は `--dangerously-skip-permissions`。
- **OpenCode の思考抑制**は `-m "deepseek/deepseek-flash#none"`
  （`#low` / `#high` / `#max`）。整形・分類・抽出のような機械的作業で使う。

## 6. モデル同一性（Strict Model Fidelity）

- 最初に指定・意図されたモデルと完全に同一のモデルを CLI 引数に指定する。
- 勝手に別モデルへ昇格・降格しない。
- `w1` は日常実装の**役割名**であり、環境やタスク制約に応じたモデルの割当は
  正本（`rules/models.md` §2.5、`docs/routing.md` §2–§4）に従う。
  モデル名が明示された場合は、そのモデルと正本のチャネル・設定を厳守する。
  CLI の引数・停止条件は該当ハーネスのスキルを参照する。
- 指定モデルの枠（クォータ・コスト）を厳守する。

## 7. 親の振る舞い

- 子の完了ステータス、成果物のコミットハッシュ、要約だけを親コンテキストに
  戻す。中間ログは持ち込まない。

## 8. チャネルの目安

優先の目安。各タスク・環境における割当正本は `rules/models.md` §2.5 および
`docs/routing.md` を参照する。

1. **実装・多段（編集→pytest→修正）**:
   - **T3 Code 環境**: ネイティブ委譲のチャネル・作業別モデル・設定は
     `rules/models.md` §2.5 を参照する。
   - **非 T3 Code 環境（Claude Desktop Code モード / Cursor / 端末 CLI）**:
     CLI ラッパー `codex-sub --repo <dir> --prompt "..."`
     （`rules/models.md` §2.5）。上限時は停止し API へ自動切替しない。
   - **機密（Private）**: Composer 2.5（非 Fast）。T3 `delegate_task` または
     CLI。
2. **敵対レビュー・視点提案・採点（read-only・短時間・戻り値で足りる）**:
   モデルは `rules/models.md` §2.5 の暫定指示を優先する（恒久方針はループ末
   Opus 5.5、T1/T2/T3 は当面なし）。Gemini 4 Hydrogen・旧 3.8 Flash は使わない。
3. **コンテキスト分離**: 別 BRIEF は `/clear` または別スレッド。
   モデル切替は `/model`。
4. **モデル名を先頭に（可視性）**: Cursor Task の `description` は
   `{通称} {短い作業}`（例: `Fable open-artifact audit`）。通称は人が呼ぶ
   名前だけ（Grok / Fable / Composer / Gemini Pro / Gemini Hydrogen / Gemini Flash）。
   版数・slug は書かない。inherit なら親と同じ。agy / CLI は呼ぶ直前に
   チャットへ `{通称} を呼び出します` を1行。
5. **Cursor を `delegate_task` で呼ぶとき**: `target.options` に
   `{"fastMode": false}` を必ず明示し、応答の `options` で確認する。
   未指定は Fast で動く（2026-10-23 実測）。`rules/models.md` §2。
   - **既存スレッドへの追補**: スレッドは作成時の設定を引き継ぐ。options が
     無い旧スレッドは、追補の前に `t3_thread_configure`
     （`modelSelection.options` に `fastMode: false` と effort）で直し、
     `t3_thread_configuration` で確認してから `t3_thread_send` する。
     「新規起票して brief を付け直す」で回避しない（子の文脈が失われる）。
   - CLI（`cursor-agent`）は既定が非 Fast（`~/.cursor/cli-config.json` の
     `fast: false`）なので、ガードで遮断はしない。`-fast` 付き ID を自分で
     選ばないこと。問題は T3 経由の `delegate_task` だけ。

## 9. 敵対レビューのスコープ

1. **正本に無い使用上限を発明しない**（例: Fable 1日1回、別 BRIEF の
   別日必須、案Aと案Bの同日禁止）。
2. **「同日同問」は Fable↔Opus（または同役二重）に限定**。Fable の
   別 BRIEF・別セッションでの同日 A→B は禁止理由にしない。
3. 疑わしい制限指摘は severity を `major` にせず `nit` とし、正本の該当行を
   引用必須。引用できなければ指摘しない。

## 10. ファイル所有権

同じリポジトリで別スレッドが稼働中なら、そのスレッドが触っているファイルを
編集しない。

- `git add -A` を使わない。パスを明示して stage する（相手の `scratch/`
  等を巻き込まない）。
- commit は相手スレッドが terminal になってから。
- worktree 分離はルール共有を切らない（`AGENTS.md` が symlink で
  本体を読むため）。

## 11. MCP（Linear 等）

外部 MCP を繋ぐときは、**読み取りは自由・書き込みは明示指示があるときだけ**に
する。

- 起票・更新・クローズ・コメント投稿は「指示された1操作」に限る。
  まとめて作らない。
- 接続設定（`opencode mcp add` / `claude mcp add`）は
  `~/.config/opencode/opencode.jsonc` 等に入る。**T3 稼働中に T3 側の設定を
  書き換えない**。
