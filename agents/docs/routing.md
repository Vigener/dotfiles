# モデルルーティング表（2026-10-30）

> 方針・禁止事項は `agents/rules/models.md` が正本。本書は「タスク → モデル」の対応表。
> 残量・リセットは
> `~/dotfiles/bin/update-ai-usage --format markdown --no-notify --no-write-runcat`
> で取得する。**数値は本書に書かない。**

## 1. 判定順序

1. **環境**: ローカル（T3 / CLI）か **Cursor Cloud Agent** か。Cloud は本書 §3「Cursor Cloud Agent」を先に適用する。
2. **Phase-First Override**: 教員報告前・数理難所・章立て・仕様策定の山場なら、**Opus 5.5**（`models.md` §3.6 **要申請**、ループ頭設計と別）または Sonnet 5.5 (medium) を投入する。Argon は設計に使わない。モデルと effort は別軸（`rules/models.md` 3.5）。
3. **Task**: Design / Implement / Extract を判定。見た目で合否が決まる成果物は Task を増やさず、本書 §3 Visual QA を適用する。
4. **Flag**: Private / Search / Orchestration を判定。
5. **チャネル**: `in agy` / `in claude` / `dsh-sub` / `in cursor`（例外のみ）の指定を確認。省略時は下のフォールバック順。
6. **残量**: 動的振り分けはしない。使い切り防止の確認に `update-ai-usage` を使う（`rules/models.md` §2.9）。

## 2. Task × Flag 早見表（ローカル）

| Task / Flag | 役割 | 第一候補 | 代替 |
|---|---|---|---|
| **Design（ループ頭）** | 方向・骨子・DoD | `claude: Opus 5.5`（high・`models.md` §3.6 申請不要） | — |
| **Design（細部）** | 仕様・疑似コード | `agy: Sonnet 5.5` (medium) | `claude: Sonnet 5.5` (Team) |
| **Design（発想）** | アイデア・問いの立て直し | `agy: Gemini 4 Argon` (medium) | Web Argon |
| **Implement（中段）** | 打鍵・実装・リファクタ（W1） | `dsh-sub`（`deepseek-flash`） | — |
| **Implement（後段）** | Diff 敵対監査 | T1=`dsh-sub`、T2=Sonnet 5.5 (medium)、T3=Sonnet 5.5 (medium) | ループ末 Opus 5.5（`models.md` §3.6 申請不要） |
| **Extract / W2** | 大量走査・ログ要約・一覧化・整形 | `agy: Gemini 3.8 Flash` | DeepSeek Free（OpenCode・常用しない） |
| **Flag: Private** | 機密・生活メモ・認証情報 | `cursor: Composer 2.5`（非 Fast） | `claude`（Team） |
| **Flag: Search** | Web 調査・最新動向 | `agy: Gemini 3.8 Flash` | — |
| **Flag: Orchestration** | サブエージェント指揮・並行管理 | `claude: Opus 5.5`（Team） | T3 `delegate_task` |
| **推敲（ループ末）** | 人が読む日本語 | yomiyasu（本体） + **Gemini 3.8 Flash** | — |

## 3. 役割別モデル（ローカル）

| 役割 | 第一候補 | 代替 | チャネル |
|---|---|---|---|
| 司令塔（オーケストレーター） | **Opus 5.5**（Claude Team） | — | T3 / `claude` |
| 設計（ループ最初の 1 回） | Opus 5.5（high・`models.md` §3.6 申請不要） | — | claudeAgent / `claude` |
| 細かい仕様 | Sonnet 5.5 (medium) | Sonnet 5.5 (Team) | agy / claudeAgent |
| 発想のみ | Gemini 4 Argon (medium) | Web Argon | agy |
| 敵対レビュー T1 | **`dsh-sub`**（1017） | W1 直後は Sonnet 5.5 (medium) | CLI |
| 敵対レビュー T2 | Sonnet 5.5 (medium) | — | agy / claudeAgent |
| 敵対レビュー T3 | Sonnet 5.5 (medium) | — | agy / claudeAgent |
| ループ最後のレビュー | Opus 5.5（1 回・`models.md` §3.6 申請不要） | — | claudeAgent |
| 実装ループ（W1） | **`dsh-sub`**（DeepSeek-V4.1-Flash-1017） | — | CLI |
| 難所の実装（W3） | Sonnet 5.5 (medium) | **Opus 5.5**（前提崩れ・同指摘2回） | claudeAgent / agy |
| 探索・走査（W2） | Gemini 3.8 Flash | DeepSeek Free | agy / opencode |
| Visual QA フォールバック / Opus 不在時の司令塔代行 | Grok 4.7（Cursor・非 Fast） | — | cursor / T3 |
| 機械的採点 | ローカル Python (pytest) | — | — |

- effort は既定 **medium**。high は「何が良いか自体を決める」案件だけ（`rules/models.md` 3.5）。
- 前提崩れ・同じ指摘 2 回 → **Sonnet 5.5 high ではなく Opus 5.5** へ。回数と理由を記録（RES-23 と合わせて分析）。

### Cursor Cloud Agent（変更しない）

| 役割 | モデル | Fast |
|---|---|---|
| 設計 | Grok 4.7 | **必ず off** |
| 実装 | Composer 2.5 | **必ず off** |

### Worker の分業

| 層 | 既定 | 代替 | 使う場面 |
|---|---|---|---|
| **W1 日常実装** | **`dsh-sub`**（`deepseek-flash` / effort `high`） | `deepseek-v4-pro` + `max`（難所・常用禁止） | 編集 → テスト → 修正 |
| **W2 大文脈の偵察** | Gemini 3.8 Flash（agy） | DeepSeek Free（OpenCode） | 全体把握・ログ要約・一覧化・整形 |
| **W3 難所** | Sonnet 5.5 (medium) | Opus 5.5 | 前提が崩れた、または同じ指摘が 2 回 |

- Free は **期間限定・SLA なし・OpenCode 内限定**。W1 の代替にしない。
- ローカルでは **Composer 2.5 を W1 に使わない**（Private と Cloud Agent 実装を除く）。

### Visual QA（図・PNG・HTML レイアウト）

成果物の合否が「見て決まる」仕事（matplotlib の論文図、凡例、キャプション、HTML の重なり）は、スクリプト実装と目視を分ける。Task 列に Visual は足さない。画像生成モデルも経路に入れない。Composer を図禁止にもしない。

- **スクリプト・数値・フォント・再現性**: W1（`dsh-sub`）。ここは閉じた Implement。
- **PNG / 画面の目視**: W1 の自己申告は証拠にしない。**第一候補は Gemini 3.8 Flash**（agy・マルチモーダル）。**フォールバックは Grok 4.7**（Cursor・非 Fast）。Grok 4.7 がローカルで PNG をどこまで判断できるかは**未確認**（試す前に期待値を上げない）。DeepSeek / Composer に「PNG を見て重なりなしと報告せよ」とだけ頼まない。**通常の Visual QA に Opus 5.5 は使わない**（引き上げ時のみ `models.md` §3.6）。
- **最初の 1 回の見た目直しは想定内**。同じ見た目クラス（重なり・余白・改行）が 2 回目に出たら W1 ループを止める（本書 §6 の「同じ指摘が 2 回続く」を図にも適用）。親が figsize / `subplots_adjust` / fontsize / overlap assert を閉じてから W1 に 1 通り出すか、**Opus 5.5 へ引き上げ**する。
- overlap のプログラム検査は初回 brief に入れる。検査を通すために目盛りを消すのは不合格。
- 論文図は matplotlib。T3 の `html_preview` はチャット用 HTML であり、論文 PNG の代替にしない。

### Grok 4.7（ローカルでの位置づけ）

- **司令塔・設計の主軸にしない**（平常時のオーケストレーターは Opus 5.5）。
- **用途（この2つのみ）**: **Visual QA フォールバック**（Flash のあと）、**Opus 5.5 が使えないときのオーケストレーター代行**（Opus 不在時に代行できるのが Grok だけで、Grok の枠はリセットまでが長いため温存する）。
- **Fast は使わない**（`rules/models.md` §2.1、`rules/delegation.md` §8、`docs/routing.md` §8）。T3 `delegate_task` は `fastMode: false` 必須。
- Maker-Breaker: W1 が DeepSeek のとき Breaker は **Sonnet 5.5 (medium)**（W1 直後 T1・T2–T3）。

### yomiyasu

- 大きなループの**終わり**、Gemini 3.8 Flash が推敲を担当。CLI は `nanaism/yomiyasu` の**本体**（2026-10-30 決定。詳細は RES-24）。
- 【】接頭辞・見出し・箇条書き・番号・数値を保持。推敲後 diff 確認。

## 4. 環境の指定とフォールバック

| 記法 | 契約 | 実行 |
|---|---|---|
| `w1 in api` | DeepSeek 従量（1017） | `dsh-sub --repo … --prompt …`（スキル `deepseek-harness`） |
| `flash in agy` | Google AI Pro（Gemini 枠） | 探索・Search・W2・Extract・整形・Visual QA・yomiyasu（推敲）。`gemini-3.8-flash-high` / `agy` |
| `argon in agy` | Argon 独立週枠 | **発想のみ** `gemini-4-argon-medium` |
| `sonnet in agy` | Google AI Pro（Claude 週枠） | `agy --model claude-sonnet-5-5-medium` |
| `opus in claude` | **Claude Team** | T3 `claudeAgent` / `claude -p`（オーケストレーター・ループ頭尾） |
| `composer in cursor` | Cursor Pro | **Private のみ**（非 Fast 明示） |
| `grok in cursor` | Cursor Pro | Visual QA フォールバック・Opus 不在時の司令塔代行（非 Fast）。Cloud 設計は Cloud Agent 経路 |
| `fable in cursor` | Cursor Other Models | 要許可 |
| `deepseek in opencode` | OpenCode Free | W2 補助のみ。W1 にしない |
| `cloud design` | Cursor Cloud | Grok 4.7 非 Fast |
| `cloud implement` | Cursor Cloud | Composer 2.5 非 Fast |

**モデル→プロバイダは固定**（カタログに出ていても、契約が違うプロバイダでは選ばない）

| モデル | 使うプロバイダ | 選ばない先 |
|---|---|---|
| W1 DeepSeek 1017 | `dsh-sub` | opencode Free を W1 にしない |
| Argon | `antigravity` | 設計・仕様には使わない |
| Sonnet 5.5 | `agy` → Team | cursor |
| Opus 5.5 | `claudeAgent` / Team | cursor、agy（余剰時のみ・要許可） |
| Fable 5.1 | `cursor` のみ | それ以外 |
| Composer / Grok | `cursor` | ローカル W1・設計には使わない（Private / Cloud / `rules/models.md` §2.1 の Grok 例外のみ） |
| Gemini 3.8 Flash | `agy` | 実装 W1 |

**環境省略時（ローカル）**:

- **オーケストレーション**: Opus 5.5（Team）。
- **設計**: Opus 5.5（ループ頭 1 回）→ Sonnet 5.5 (medium)（細部）→ 前提崩れ・同指摘 2 回で Opus 5.5。
- **実装（W1）**: `dsh-sub` のみ。
- **探索・Search・Extract・整形**: Gemini 3.8 Flash。
- **Claude**: Sonnet 5.5 は agy → Team。Opus 5.5 は Team 優先。

公式 API への自動フォールバックは禁止（明示指示があるときのみ）。

## 5. Claude 5.x の役割と設定

| モデル | 役割 | 設定 | 原則 |
|---|---|---|---|
| Opus 5.5 | オーケストレーター・ループ頭の設計・ループ末レビュー・**裁定** | `effort: high` | ループ頭/末・引き上げは `models.md` §3.6 申請不要。**裁定のみ等は要申請** |
| Sonnet 5.5 | 細仕様・W3・敵対レビュー **T2–T3** | `effort: medium` | DoD まで自律完遂 |
| Fable 5.1 | 特別顧問 | `effort: high` | 日常禁止。軸崩壊時のみ |
| Haiku 5.5 | 配管（非推奨） | `effort: low` | 探索は Gemini 3.8 Flash |

## 6. 昇格・降格トリガー

**昇格**

- 同じ指摘が 2 回続く / 設計の前提が崩れた → **Opus 5.5**（Sonnet 5.5 high より優先。**`models.md` §3.6 申請不要**）
- 論文の主張・章立てに触れる
- セキュリティ・再現性・計算量の判断
- 敵対レビューで `major` 以上

**降格**

- 仕様が固まり、実装が機械的（W1 `dsh-sub`）
- テストが通り、残りが整形・ログ要約（Gemini 3.8 Flash）。人が読む文章の推敲は yomiyasu（`rules/models.md` §2.8）
- 同じモデルで 2 回連続して新しい指摘が出ない

昇格回数・理由をログに残す（RES-23）。

## 7. 残量（ペース配分の変更）

- **動的ペース振り分けはしない**（`model-route` から削除済み）。
- **Cursor 月枠**: 周期末に **数 % 残す**（Cloud Agent 用）。「1 週間前に使い切る」方針は廃止。
- **agy 週枠 / Cursor 月次**: リセット前に余っていても、**本人が明示的に呼ぶまで**追加消費しない。
- Other Models（Fable）は許可時のみ。
- **計測期間 RES-23（〜2026-11-07）**: W1 `dsh-sub` と Claude Team 残量を記録（`rules/models.md` §0）。
- 実測は `update-ai-usage`。数値は本書に書かない。

## 8. 禁止

- **Fable 5.1 を許可なく Cursor で呼ぶ**。
- **Argon を設計・仕様・W1 前段に使う**。
- **ローカル W1 に Gemini Flash / Composer を使う**（Private / Cloud Agent を除く）。
- `Private` フラグのタスクを agy に投げる。
- 明示指示なしに Anthropic / OpenAI の従量 API を使う。
- 指定モデルを勝手に昇格・降格する。
- Free を W1 の唯一経路にしない。
- **Cursor Cloud 以外で Grok を設計主軸にする**（Visual QA フォールバック・Opus 不在時の代行を除く）。
- **Cursor の Fast を使う**（Cloud / Private / Grok 例外でも off 明示）。

### Grok / Composer の Fast ガード（T3・CLI）

- T3 `delegate_task` で Cursor モデルを呼ぶとき `target.options` に `{"fastMode": false}` を**必ず**明示。応答の `options` で確認。
- CLI は `-fast` 付き ID を使わない。`cursor-agent --list-models` / `~/.cursor/cli-config.json` の `fast: false` を参照（`rules/delegation.md` §8）。

## 9. 履歴メモ（2026-10-21 ベイクオフ）

DeepSeek Free vs Composer 2.5 の比較は `logs/worker-bakeoff-2026-10-21.md`。
**2026-10-30**: ローカル W1 を **`dsh-sub`（1017）** に固定。Flash / Composer の W1 順序は廃止。
