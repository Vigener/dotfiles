# モデルルーティング表（2026-11-04）

> 方針・禁止事項・割当の事実正本は `agents/rules/models.md`。本書はタスクと
> モデルの対応表。
> 残量・リセットは
> `~/dotfiles/bin/update-ai-usage --format markdown --no-notify --no-write-runcat`
> で取得する。**数値は本書に書かない。**
>
> **適用範囲**: Opus 司令塔・ループ頭設計は研究の既定。研究以外の司令塔は
> Grok（非 Fast）または Gemini Flash（`rules/models.md` §2.5）。個別の
> 役割指定・Private 制約を優先する。

## 1. 判定順序

1. **環境**: ローカル（T3 / CLI）か **Cursor Cloud Agent** か。Cloud は
   本書 §3「Cursor Cloud Agent」を先に適用する。
2. **Phase-First Override**: 教員報告前・数理難所・章立て・仕様策定の山場なら、
   **Opus 5.5**（`models.md` §3.6 **要申請**、ループ頭設計と別）を投入する。
   Sonnet 5.5 (medium) は**名指しのときだけ**。Argon は設計に使わない。
   モデルと effort は別軸（`rules/models.md` §3.5）。
3. **Task**: Design / Implement / Extract を判定。見た目で合否が決まる成果物は
   Task を増やさず、本書 §3 Visual QA を適用する。
4. **Flag**: Private / Search / Orchestration を判定。
5. **チャネル**: `in agy` / `in claude` / `codex-sub` / `dsh-sub`（明示 DeepSeek）/
   `argon-sub`・`flash-sub`・`gemini-sub`（Google weekly limit 時・明示時）/
   `in cursor`（例外のみ）の指定を確認。省略時は下のフォールバック順。
6. **残量**: 動的振り分けはしない。使い切り防止の確認に `update-ai-usage` を
   使う（`rules/models.md` §2.9）。
>
> **ループ末監査の暫定例外**: `rules/models.md` §2.5「暫定監査」を優先する。
> 本書内の Opus レビュー役の記述は恒久方針であり、暫定中は同節の
> Argon medium に置き換える。設計・引き上げの役割は変えない。
>
> **Carbon**: Google AI Pro に来る前提。手順はスキル `model-route`
> 「Argon と Carbon」。`antigravity` に出るまで呼ばない。導入価格の
> 終了後も、Argon の安い代替にはしない。
>
> **DeepSeek の代替欄**: `rules/models.md` §2.5 の利用条件付き。
> 枠不足・エラーだけでは自動利用しない。Codex CLI ラッパーは API へ
> 自動切替しない。

## 2. Task × Flag 早見表（ローカル）

| Task / Flag | 役割 | 第一候補 | 代替 |
| --- | --- | --- | --- |
| **Design（ループ頭）** | 方向・骨子・DoD | `claude: Opus 5.5`（high・申請不要） | — |
| **Design（細部）** | 仕様・疑似コード | `codex-sub`（effort medium） | 条件付き `dsh-sub` |
| **Design（発想）** | アイデア・問いの再構築 | `agy: Gemini 4 Argon` (medium) | Web Argon |
| **Implement（中段）** | 打鍵・実装・修正（W1） | `codex-sub`（T3 は §3 参照） | 条件付き `dsh-sub` |
| **Implement（後段）** | 敵対的監査（Breaker） | 暫定監査 Argon medium (*1) | — |
| **Extract / W2** | 大量走査・要約・整形 | `agy: Gemini 3.8 Flash` | — |
| **Flag: Private** | 機密情報 | `cursor: Composer 2.5`（非 Fast） | `claude`（Team） |
| **Flag: Search** | Web 調査・最新動向 | `agy: Gemini 3.8 Flash` | — |
| **Flag: Orchestration** | 指揮・並行管理 | `claude: Opus 5.5`（Team） | T3 委譲 |
| **推敲（ループ末）** | 人が読む日本語 | yomiyasu（本体） + **Flash** | — |

(*1) `rules/models.md` §2.5「暫定監査」を優先。恒久方針はループ末 Opus 5.5。
T1/T2/T3 は当面なし。

## 3. 役割別モデル（ローカル）

タスクごとの第一候補は §2 を参照する。Codex 内の作業別モデル・effort、
W1/W2/W3、監査担当・回数・引き上げの条件は `rules/models.md` §2.5 が正本。
研究／非研究の区別と、同節の暫定指示を適用する。

### Cursor Cloud Agent（変更しない）

| 役割 | モデル | Fast |
| --- | --- | --- |
| 設計 | Grok 4.7 | **必ず off** |
| 実装 | Composer 2.5 | **必ず off** |

### Visual QA（図・PNG・HTML レイアウト）

成果物の合否が「見て決まる」仕事（matplotlib の論文図、凡例、キャプション、
HTML の重なり）は、スクリプト実装と目視を分ける。Task 列に Visual は足さない。
画像生成モデルも経路に入れない。Composer を図禁止にもしない。

- **スクリプト・数値・フォント・再現性**: W1（`codex-sub` / フォールバック
  `dsh-sub`）。ここは閉じた Implement。
- **PNG / 画面の目視**: W1 の自己申告は証拠にしない。**第一候補は
  Gemini 3.8 Flash**（agy・マルチモーダル）。**フォールバックは Grok 4.7**
  （Cursor・非 Fast）。Grok 4.7 がローカルで PNG をどこまで判断できるかは
  **未確認**（試す前に期待値を上げない）。DeepSeek / Composer に「PNG を見て
  重なりなしと報告せよ」とだけ頼まない。**通常の Visual QA に Opus 5.5 は
  使わない**（引き上げ時のみ `models.md` §3.6）。
- **最初の 1 回の見た目直しは想定内**。同じ見た目クラス（重なり・余白・改行）
  が 2 回目に出たら W1 ループを止める（本書 §6 の「同じ指摘が 2 回続く」を
  図にも適用）。親が figsize / `subplots_adjust` / fontsize / overlap assert を
  閉じてから W1 に 1 通り出すか、**Opus 5.5 へ引き上げ**する。
- overlap のプログラム検査は初回 brief に入れる。検査を通すために目盛りを
  消すのは不合格。
- 論文図は matplotlib。T3 の `html_preview` はチャット用 HTML であり、
  論文 PNG の代替にしない。

### Grok 4.7（研究タスクのローカルでの位置づけ）

- **司令塔・設計の主軸にしない**（平常時のオーケストレーターは Opus 5.5）。
- **用途（この2つのみ）**: **Visual QA フォールバック**（Flash のあと）、
  **Opus 5.5 が使えないときのオーケストレーター代行**（Opus 不在時に代行
  できるのが Grok だけで、Grok の枠はリセットまでが長いため温存する）。
- **Fast は使わない**（`rules/models.md` §2.1、`rules/delegation.md` §8、
  `docs/routing.md` §8）。T3 `delegate_task` は `fastMode: false` 必須。
- Maker-Breaker: Maker は Codex（フォールバック DeepSeek）。Breaker は
  `rules/models.md` §2.5「暫定監査」（恒久方針はループ末 Opus 5.5 のみ）。

### yomiyasu

- 大きなループの**終わり**、Gemini 3.8 Flash が推敲を担当。CLI は
  `nanaism/yomiyasu` の**本体**（2026-10-30 決定。詳細は RES-24）。
- 【】接頭辞・見出し・箇条書き・番号・数値を保持。推敲後 diff 確認。

## 4. 環境の指定とフォールバック

| 記法 | 契約 | 実行 |
| --- | --- | --- |
| `w1 in codex` | ChatGPT Plus（Codex CLI） | `codex-sub --repo … --prompt …` |
| `w1 in api` | DeepSeek 従量（1017） | `dsh-sub --repo … --prompt …`（条件付き控え） |
| `flash in agy` | Google AI Pro（Gemini 枠） | 探索・W2・整形・Visual QA・推敲 |
| `argon in agy` | Argon 独立週枠 | 発想・暫定監査（`rules/models.md` §2.5） |
| `carbon in agy` | Google AI Pro（来る前提。掲載後） | 限界を試す作業（スキル `model-route`） |
| `sonnet in agy` | Google AI Pro（Claude 週枠） | 名指し時のみ |
| `opus in claude` | **Claude Team** | オーケストレーター・ループ頭尾 |
| `composer in cursor` | Cursor Pro | **Private のみ**（非 Fast 明示） |
| `grok in cursor` | Cursor Pro | Visual QA 目視・司令塔代行（非 Fast） |
| `fable in cursor` | Cursor Other Models | 要許可 |
| `cloud design` | Cursor Cloud | Grok 4.7（非 Fast） |
| `cloud implement` | Cursor Cloud | Composer 2.5（非 Fast） |

**モデル→プロバイダは固定**（カタログに出ていても契約外では選ばない）

| モデル | 使うプロバイダ | 選ばない先 |
| --- | --- | --- |
| W1 Codex | `codex-sub` / T3 `codex` | API キー Codex・Private への Codex は禁止 |
| W1 DeepSeek | `dsh-sub`（条件付き） | Free は使わない |
| Argon | 通常 `antigravity` (*4) | 設計・仕様には使わない |
| Carbon | `antigravity`（掲載後。`rules/models.md` §1.1） | cursor。未掲載の間は呼ばない |
| Sonnet 5.5 | `agy` → Team | cursor |
| Opus 5.5 | `claudeAgent` / Team | cursor、agy（余剰時のみ・要許可） |
| Fable 5.1 | `cursor` のみ | それ以外 |
| Composer / Grok | `cursor` | ローカル W1・設計には使わない（例外のみ） |
| Gemini 3.8 Flash | `agy` | 実装 W1 |

(*4) weekly limit 到達時の Google API 例外は `rules/models.md` §0.5 を参照。

**環境省略時（ローカル）**:

省略時は §2–§3 に従う。研究／非研究と実行環境を先に判定し、
監査の暫定指示は `rules/models.md` §2.5 を確認する。

Anthropic / OpenAI の従量 API への自動フォールバックは禁止（明示指示が
あるときのみ）。既存の W1 DeepSeek fallback は `rules/models.md` §2.5 の
許可境界に従う。

## 5. Claude 5.x の役割と設定

| モデル | 役割 | 設定 | 原則 |
| --- | --- | --- | --- |
| Opus 5.5 | 司令塔・設計・レビュー・裁定 | `effort: high` | ループ頭/末・引き上げは申請不要。裁定等は要申請 |
| Sonnet 5.5 | 名指し時のみ（細仕様・旧 W3 等） | `effort: medium` | 既定経路からは外す |
| Fable 5.1 | 特別顧問 | `effort: high` | 日常禁止。軸崩壊時のみ |
| Haiku 5.5 | 配管（非推奨） | `effort: low` | 探索は Gemini 3.8 Flash |

## 6. 昇格・降格トリガー

### 昇格

- 同じ指摘が 2 回続く / 設計の前提が崩れた → **Opus 5.5**
  （Sonnet 5.5 high より優先。**`models.md` §3.6 申請不要**）
- 論文の主張・章立てに触れる
- セキュリティ・再現性・計算量の判断
- 敵対レビューで `major` 以上

### 降格

- 仕様が固まり、実装が機械的（W1 `codex-sub` / フォールバック `dsh-sub`）
- テストが通り、残りが整形・ログ要約（Gemini 3.8 Flash）。人が読む文章の
  推敲は yomiyasu（`rules/models.md` §2.8）
- 同じモデルで 2 回連続して新しい指摘が出ない

昇格回数・理由をログに残す（RES-23）。

## 7. 残量（ペース配分の変更）

- **動的ペース振り分けはしない**（`model-route` から削除済み）。

- **Cursor 月枠**: 周期末に **数 % 残す**（Cloud Agent 用）。「1 週間前に
  使い切る」方針は廃止。
- **agy 週枠 / Cursor 月次**: リセット前に余っていても、**本人が明示的に
  呼ぶまで**追加消費しない。
- Other Models（Fable）は許可時のみ。
- **計測期間 RES-23（〜2026-11-07）**: `rules/models.md` §0 と同じ 5 系統
  （Codex 残・Codex タスク・Opus 差戻・Claude Team・Cursor・Gemini・
  DeepSeek USD）。`logs/res23/README.md`。
- 実測は `update-ai-usage`。数値は本書に書かない。

## 8. 禁止

- **Fable 5.1 を許可なく Cursor で呼ぶ**。
- **Argon を設計・仕様・W1 前段に使う**。
- **Carbon を、未掲載のチャネル、Argon の担当、または導入価格終了後の安い代替として使う**
  （スキル `model-route`「Argon と Carbon」）。
- **ローカル W1 に Gemini Flash / Composer を使う**（Private / Cloud Agent
  を除く）。
- `Private` フラグのタスクを agy に投げる。
- 明示指示なしに Anthropic / OpenAI の従量 API を使う。
- **Codex を API キー（`OPENAI_API_KEY`）で呼ぶ**。
- **Private タスクを Codex に出す**。
- **Codex の Fast を使う**。
- 指定モデルを勝手に昇格・降格する。
- DeepSeek Free は使わない。
- **研究で Cursor Cloud 以外の Grok を設計主軸にする**（Visual QA
  フォールバック・Opus 不在時の代行を除く）。
- **Cursor の Fast を使う**（Cloud / Private / Grok 例外でも off 明示）。

### Grok / Composer の Fast ガード（T3・CLI）

- T3 `delegate_task` で Cursor モデルを呼ぶとき `target.options` に
  `{"fastMode": false}` を**必ず**明示。応答の `options` で確認。
- CLI は `-fast` 付き ID を使わない。`cursor-agent --list-models` /
  `~/.cursor/cli-config.json` の `fast: false` を参照（`rules/delegation.md` §8）。

## 9. 履歴メモ（非規範）

本節の内容は当時の経緯の記録であり、**現行の指示・規範ではない**。
現行の正本は `rules/models.md` および本書の現行節を参照すること。

- **2026-10-21**: DeepSeek Free vs Composer 2.5 のベイクオフ比較
  （`logs/worker-bakeoff-2026-10-21.md`）。
- **2026-10-30**: ローカル W1 を `dsh-sub`（1017）に固定。Flash / Composer の
  W1 順序は廃止。
- **2026-11-01**: RES-23 に合わせ W1 の第一候補を Codex（`codex-sub`）に移行。
  契約前・枠切れは `dsh-sub` 控え。T2 の Sonnet 敵対レビューは停止
  （Breaker はループ末 Opus、暫定は Argon medium）。

## Typstの分担（共通workflow）

Typst 執筆の共通手順は `agents/skills/typst-workflow/SKILL.md` を各エージェントが
明示 read する。詳細なモデル分担・実行制約の事実正本は `rules/models.md`
「Typst」を参照する（表の複製は行わない）。

実行制約も同じ正本に従う。担当・設定の一覧は本書に複製しない。
