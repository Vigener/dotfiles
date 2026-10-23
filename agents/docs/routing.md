# モデルルーティング表（2026-10-21）

> 方針・禁止事項は `agents/rules/models.md` が正本。本書は「タスク → モデル」の対応表。
> 残量・リセット・消費ペースは
> `~/dotfiles/bin/update-ai-usage --format markdown --no-notify --no-write-runcat`
> で取得する。**数値は本書に書かない。**

## 1. 判定順序

1. **Phase-First Override**: 教員報告前・数理難所・章立て・仕様策定の山場なら、残量ペースを無視して最高峰（Argon / Sonnet 5.5 / Opus 5.5）を投入する。ただし **モデルと effort は別軸**で、最高峰モデルを選ぶことは high effort を選ぶことを意味しない（`rules/models.md` 3.5）。
2. **Task**: Design / Implement / Extract を判定。見た目で合否が決まる成果物は Task を増やさず、§3 Visual QA を適用する。
3. **Flag**: Private / Search / Orchestration を判定。
4. **環境**: `in agy` / `in cursor` / `in claude` / `api` の指定を確認。省略時は下のフォールバック順。
5. **コスト階層**: 低 / 中 / 高 と現在の残量で最終決定。

## 2. Task × Flag 早見表

| Task / Flag | 役割 | 第一候補 | 代替 |
|---|---|---|---|
| **Design** | 研究方針・論理・意思決定・敵対レビュー・数理検証 | `agy: Gemini 4 Argon` | `claude: Opus 5.5`（要許可） / `agy: Sonnet 5.5` / Web Argon |
| **Implement（前段）** | 仕様化・疑似コード | `agy: Gemini 4 Argon` | `claude: Sonnet 5.5` |
| **Implement（中段）** | 打鍵・実装・リファクタ | `agy: Gemini 3.8 Flash` | `cursor: Composer 2.5` / `claude: Sonnet 5.5 (medium)` |
| **Implement（後段）** | Diff 敵対監査 | `agy: Gemini 4 Argon` | `claude: Opus 5.5`（要許可） |
| **Extract** | 大量走査・ログ要約・一覧化 | `agy: Gemini 3.8 Flash` | `cursor: Composer 2.5` |
| **Flag: Private** | 機密・生活メモ・認証情報 | `cursor: Composer 2.5` / `cursor-agent` | `claude`（Team） |
| **Flag: Search** | Web 調査・最新動向 | `agy: Gemini 3.8 Flash` | `agy: Gemini 4 Argon`（批判的読解） |
| **Flag: Orchestration** | サブエージェント指揮・並行管理 | `delegate_task`（T3） | `agy: Gemini 4 Argon`（Cursor 枠逼迫時） |

## 3. 役割別モデル

| 役割 | 第一候補 | 代替 | チャネル |
|---|---|---|---|
| 司令塔（日常） | Gemini 3.8 Flash / Grok 4.6 | Claude Sonnet 5.5 (Team) | T3 / CLI |
| 設計・仕様化 | Gemini 4 Argon (medium) | Opus 5.5（high・要許可） / Sonnet 5.5 (medium) | agy / T3 |
| 敵対レビュー | Argon (medium) + Sonnet 5.5 (medium) の2本立て | Opus 5.5（high・要許可） | agy / T3 / claudeAgent |
| 実装ループ（W1） | Gemini 3.8 Flash（agy） | Composer 2.5（Cursor）。緊急時のみ `dsh-sub` | agy / cursor / T3 |
| 難所の実装（W3） | Sonnet 5.5 (medium) | Opus 5.5 | claudeAgent / T3 |
| 探索・量産（W2） | Gemini 3.8 Flash | DeepSeek Free（1M） | agy / opencode |
| 裁定・袋小路 | Opus 5.5（要許可） | Fable 5.1（特別顧問・要許可） | claude（agy は週枠が余っているときのみ） |
| 機械的採点 | ローカル Python (pytest) | — | — |

- effort は既定 **medium**。high は「何が良いか自体を決める」案件だけ（`rules/models.md` 3.5）。
- 敵対レビューは **medium の2本立て**（別ファミリー）。high の同役二重は禁止。Sonnet 5 の high と Opus / Fable は要許可。

### Worker の分業

| 層 | 既定 | 代替 | 使う場面 |
|---|---|---|---|
| **W1 日常実装** | Gemini 3.8 Flash（agy） | Composer 2.5（Cursor） | 編集 → テスト → 修正。DeepSeek Free はあれば使ってよいが常用しない。`dsh-sub` は Cursor 月枠と Flash 週枠が両方切れた緊急枠（`rules/models.md` §2.5） |
| **W2 大文脈の偵察** | Gemini 3.8 Flash（agy） | DeepSeek Free（1M） | 全体把握・ログ要約・横断検索。 |
| **W3 難所** | Sonnet 5.5 (Team) | Opus 5.5 | 仕様が曖昧、設計判断が絡む、2回失敗した。 |

- Free は **期間限定・SLA なし・OpenCode 内限定**。外部 API からは使えない。無制限ではなく一定のリミットがあると判明したため、常用は難しい（2026-10-22 方針変更）。
- `dsh-sub` / 有料 1017 は、Cursor 月枠と Gemini Flash 週枠の**両方が切れたとき**の緊急 Worker。通常の次点にはしない。
- Free の 1017 反映は **未確定**。同一プロンプトで軌跡と冗長性を比べて確認する。
- Composer 3 が出たら W1 を再評価する。

### Visual QA（図・PNG・HTML レイアウト）

成果物の合否が「見て決まる」仕事（matplotlib の論文図、凡例、キャプション、HTML の重なり）は、スクリプト実装と目視を分ける。Task 列に Visual は足さない。画像生成モデルも経路に入れない。Composer を図禁止にもしない。

- **スクリプト・数値・フォント・再現性**: W1（Gemini 3.8 Flash / Composer 2.5）。ここは閉じた Implement。
- **PNG / 画面の目視**: W1 の自己申告は証拠にしない。親、または視覚が強いモデル（Flash / Sonnet / Argon）が画像を Read する。Composer / DeepSeek に「PNG を見て重なりなしと報告せよ」と書かない。
- **最初の 1 回の見た目直しは想定内**。同じ見た目クラス（重なり・余白・改行）が 2 回目に出たら W1 ループを止める（§6 の「同じ指摘が 2 回続く」を図にも適用）。親が figsize / `subplots_adjust` / fontsize / overlap assert を閉じてから W1 に 1 通り出すか、W3 に上げる。
- overlap のプログラム検査は初回 brief に入れる。検査を通すために目盛りを消すのは不合格。
- 論文図は matplotlib。T3 の `html_preview` はチャット用 HTML であり、論文 PNG の代替にしない。

### Grok 4.6 / 4.7 の使い分け（2026-10-23 調査）

同一 Cursor Models 枠・同単価。差は出力量と、1 回で何をさせるか。

| 用途 | モデル | 理由 |
|---|---|---|
| 司令塔（長い会話・指揮） | Grok 4.6 | 出力トークンが 4.7 の約半分。会話が伸びても枠を食いにくい |
| 単発の敵対レビュー・発想 | Grok 4.7 | コーディング系ベンチ・幻覚率で優位。単発なら冗長さのコストが小さい |
| 実装・量産 | Composer 2.5（W1） | 4.7 でのコード量産は出力 2 倍で枠に不利。従来方針のまま |

- 数値の出どころ: 4.7 の出力は約 8.1 万トークン/タスク、4.6 は約 3.6 万（Artificial Analysis。二次引用）。CursorBench 40.4→46.3%、DeepSWE 65.2→71.0% は自己申告で、独立の差は小さい（単独レビュー 28.8 対 28.7）。
- **「4.6 は指示に従順」「4.6 は長会話でクォータが減りにくい」は未検証**。直接比較の証拠は無く、4.6 にも「laziness」の声がある。理由には書かない。判断の根拠は出力量とコストにとどめる。
- **Fast は使わない**（2 倍課金とされる）。**T3 `delegate_task` で Cursor モデルを options 無しで呼ぶと Fast で動く**（2026-10-23 に Cursor ダッシュボードで `grok-4.7-high-fast` / `composer-2.5-fast` を確認。T3 の UI はスレッドに options が無いと「Fast オフ」と表示するため、UI 表示は証拠にならない。失敗時のエラーも "Increase limits for faster responses"）。Grok 4.6 / 4.7 と Composer 2.5 / 2 はカタログの `fastMode` 既定が `true`。
  - **`delegate_task` の `target.options` に `fastMode: false` を必ず明示する。未指定で呼ばない。** 応答の `options` に `fastMode: false` が返ることを確認する（`[]` なら Fast になっている）。
  - effort のキーはモデルごとに違う: 4.7 は `reasoning_effort`、4.6 は `effort`、Composer は effort 無し。既定 high。xhigh は effort 格上げとして扱う（`rules/models.md` 3.5）。
- 4.7 は `contextWindow` 既定 500k。単発では `256k` に絞ってよい。
- Maker-Breaker: Grok 4.6 と 4.7 は**同一ファミリー**。親が Grok 4.6 のとき、Breaker に Grok 4.7 は使えない（Google 系か Sonnet 5.5）。Breaker に 4.7 を使えるのは、親が xAI 以外のとき。
- `cursor-agent` の ID（2026-10-23 実測）: Fast は `-fast` 付きの別 ID で、素の ID は非 Fast。4.7 は `grok-4.7-high`（`grok-4.7` 単体も通る）、4.6 は `cursor-grok-4.6-high`（`cursor-` 接頭辞が付く）。`-fast` 付きは使わない。一覧は `cursor-agent --list-models`。CLI の既定は `~/.cursor/cli-config.json` の `modelParameters.<model>` に持ち、Composer 2.5 / Grok 4.6 / 4.7 とも `fast: false`（2026-10-23 実測）。上書きは `--model 'composer-2.5[fast=false]'` の括弧記法。**T3 の設定画面（Models）には Fast を切る既定の設定が無い**（Fast mode の対応可否の表示のみ）。T3 経由は `options` の明示で守る。

### 2026-10-21 ベイクオフの結論

DeepSeek Free と Composer 2.5 を T1（バグ修正）/ T2（リファクタ）/ T3（検証・CLI）で比較した。
詳細と限界は `logs/worker-bakeoff-2026-10-21.md`。

- **機能面は同等**: 隠しテスト 14/14、可視 10/10。T1/T2 は実質同点。
- **T3 だけ差**: Composer は `re.match` + `$` で `a\n` を通し、非文字列タグで traceback になり得る。
  DeepSeek は `fullmatch` と型検査で塞ぐ。
- **`__pycache__` の差は環境要因**。除くと Sonnet 約 297 対 297、Argon 300 対 300。
- **結論（当時）**: W1 の既定は DeepSeek Free のまま。ただし T1/T2 は Composer と同等。
  → **2026-10-22 改訂**: Free にリミットがあり常用が難しいため、W1 は Gemini 3.8 Flash → Composer 2.5。
  → **2026-10-23**: `dsh-sub` は Cursor 月枠と Flash 週枠が両方切れた緊急枠。通常の次点にはしない。
  Composer は Cursor の大量打鍵・最小差分に残す。
  Composer に T3 型を振るなら `fullmatch` と型検査を明示する。

## 4. 環境の指定とフォールバック

| 記法 | 契約 | 実行 |
|---|---|---|
| `argon in agy` | Google AI Pro（Argon 独立週枠） | T3 `delegate_task` (`antigravity` / `gemini-4-argon-medium`) または `agy --model gemini-4-argon-medium`。effort はモデル ID で選ぶ（既定 medium、high は明示判断） |
| `flash in agy` | Google AI Pro（Gemini 枠） | T3 `delegate_task` (`antigravity` / `gemini-3.8-flash-high`) または `agy` |
| `sonnet in agy` | Google AI Pro（Claude 週枠。**Sonnet の第一候補**） | `agy --model claude-sonnet-5-5-medium`（`-low` / `-high` も可。**既定 medium**。T3 には露出しない） |
| `opus in agy` | Google AI Pro（Claude 週枠。**Opus は `claude` 優先**） | `agy --model claude-opus-5-5-high`。週枠が余っているときだけ・事前許可制 |
| `composer in cursor` | Cursor Pro（**申請不要**。`fastMode: false` を明示する場合に限る） | T3 `delegate_task` (`cursor` / `composer-2.5`、options に `{"fastMode": false}` を**必ず**明示) または `cursor-agent --model composer-2.5`（`-fast` 付きは使わない） |
| `grok in cursor` | Cursor Pro（**申請不要**。`fastMode: false` を明示する場合に限る。設計・レビューの主軸にはしない）。司令塔は 4.6、単発レビュー・発想は 4.7（§3） | T3 `delegate_task` (`cursor` / `grok-4.6` または `grok-4.7`、options に `{"fastMode": false}` を**必ず**明示) または `cursor-agent --model cursor-grok-4.6-high` / `grok-4.7-high`（`-fast` 付きは使わない） |
| `fable in cursor` | Cursor Pro（**Fable 専用**・Other Models 枠） | T3 `delegate_task` (`cursor` / `claude-fable-5-1-thinking-high`) または `cursor-agent --model claude-fable-5-1-thinking-high`。事前許可制 |
| `opus in claude` | **Claude Team**（`claude auth status` で確認） | T3 `delegate_task` (`claudeAgent` / `claude-opus-5-5`) または `claude -p` |
| `deepseek in opencode` | OpenCode Free（期間限定・$0） | T3 `delegate_task` (`opencode` / `opencode/deepseek-v4.1-flash-free`) または `opencode run -m ...` |
| `deepseek 1017 in api` | DeepSeek 従量（1017 確定）。Cursor かつ Flash が切れた緊急枠 | T3 `delegate_task` (`opencode` / `deepseek/deepseek-flash`) または `dsh-sub` |
| `サブエージェント(inherit)` | 親と同一モデル | T3 `delegate_task` (`opencode` / 親モデル、options 空) または native `subagent` |

**モデル→プロバイダは固定**（カタログに出ていても、契約が違うプロバイダでは選ばない）

| モデル | 使うプロバイダ | 選ばない先 |
|---|---|---|
| Argon | `antigravity` のみ | cursor（`gemini-4-argon` が出るが選ばない） |
| Sonnet 5.5 | `agy`（CLI）→ 無ければ `claudeAgent` | cursor |
| Opus 5.5 | `claudeAgent`（CLI） | cursor、agy（週枠が余っているときのみ許可制） |
| Fable 5.1 | `cursor` のみ | それ以外（Team には無い） |
| Composer / Grok | `cursor` | それ以外 |
| DeepSeek | `opencode` / `dsh-sub` | それ以外 |

`delegate_task` の `target` は「そのプロバイダのカタログにある」ではなく「この表で許可されているか」で選ぶ。

**環境省略時**:

- **設計・探索**: ① agy（Argon / Gemini）→ ② Cursor → ③ Claude Team。
- **実装（W1）**: ① Gemini 3.8 Flash（agy）→ ② Composer（Cursor）。難所は W3（Sonnet 5.5）。Cursor と Flash が両方切れたときだけ `dsh-sub`。
- **Claude モデル**: Sonnet は ① agy の Claude 週枠 → ② Claude Team → ③ Cursor。**Opus は ① Claude Team → ② agy（週枠が余っているときのみ）→ ③ Cursor**。Fable は Cursor の Other Models のみ（要許可）。

公式 API への自動フォールバックは禁止（明示指示があるときのみ）。

## 5. Claude 5.x の役割と設定

| モデル | 役割 | 設定 | 原則 |
|---|---|---|---|
| Sonnet 5.5 | 難所の実装（W3） | `effort: medium` | DoD まで自律完遂。`high` を乱用しない |
| Opus 5.5 | 敵対監査・裁定 | `effort: high` | 不変条件と DoD だけ渡す |
| Fable 5.1 | 特別顧問 | `effort: high` | 日常禁止。軸崩壊時のみ |
| Haiku 5.5 | 配管（非推奨） | `effort: low` | 探索は Gemini 3.8 Flash を使う |

Opus / Fable は**無指定だと medium**。high は明示的に書く（Sonnet は逆に無指定が high。`rules/models.md` 3.5 の表）。

## 6. 昇格・降格トリガー

**昇格（低 → 中 → 高）**

- 同じ指摘が2回続く / 設計の前提が崩れた
- 論文の主張・章立てに触れる
- セキュリティ・再現性・計算量の判断
- 敵対レビューで `major` 以上が出た

**降格（高 → 中 → 低）**

- 仕様が固まり、実装が機械的になった
- テストが通り、残りが整形・ログ要約
- 同じモデルで2回連続して新しい指摘が出ない

## 7. ペース配分

- **Cursor Pro（月枠）**: Other Models は **Fable 専用**（温存。許可時のみ）。Grok を設計・レビューに使わず、Composer 用に空ける。更新日の約1週間前に使い切るペース。最後の1週間は Gemini 系と Cursor 無料系で回す。
- **agy（週枠）**: リセット1〜2日前に使い切るペース。余剰は発想・設計に回す。
- **Claude Team**: 5h / 週の残量を見て、日常の実装・監査に使う。使い切った場合のみ API を検討。
- 実測は `update-ai-usage`。数値は本書に書かない。

## 8. 禁止

- **Fable 5.1 を許可なく Cursor で呼ぶ**（核ボタン）。
- Cursor の Other Models 枠を Fable 以外に使う（枠は Fable 専用。GPT 系は 2026-10-21 に撤退）。
- `Private` フラグのタスクを agy に投げる。
- 明示指示なしに Anthropic / OpenAI の従量 API を使う。
- 指定モデルを勝手に昇格・降格する。
- Free を唯一の実装経路にしない。有料 1017 / `dsh-sub` は Cursor かつ Flash 枯渇時だけ。
- Free が 1017 だと断定しない（動作で確認する）。
- **Cursor の Other Models 枠を Fable 以外に使う**（枠は Fable 専用。GPT 系は 2026-10-21 に撤退）。
