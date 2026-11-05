# Codex 委譲方針の差分案（2026-11-04）

> **注意（履歴・非規範）**:
> 本書は 2026-11-04 時点での検討・差分案および議論の経緯を記録した**過去資料（非規範）**です。
> 現在の有効な指示・契約・割当の正本は `agents/rules/models.md`、`agents/rules/delegation.md`、
> および `agents/docs/routing.md` を参照してください。
> 本書内の「未採用」「未commit」「実装予定」「差分案」等の記述は当時の検討過程であり、
> 現行の規範的な指示や契約事実を規定するものではありません。

**最新状態**: 末尾「通常ルートの照合と矛盾の解消」を参照。Argon は独立した未適用メモから、人間の指示による暫定例外の差分案へ更新した。Free の W1 fallback 矛盾も解消した。以下の初回案・第2案の保留記述は履歴。


## 編集前の関連箇所（全件）

指定5ファイルから Codex／GPT モデル／effort・思考深度・格上げ規則に触れる行を列挙する。一般の effort 規則も含む。

### `rules/models.md`

```text
1: # モデル呼び出し（方針・クォータ）
16: - **残量のペースでモデルを動的に振り分けない**（手順は `model-route` から外した）。`update-ai-usage` は使い切り防止の確認に使ってよい。
18: - **計測期間（Linear RES-23、〜2026-11-07）**: 毎晩1行で **Codex 残**（ダッシュボードか `/status`）、**Codex に渡したタスク数**と **Opus の差戻回数・理由**、**Claude Team 残**、**Cursor 残**、**Gemini 残**、**DeepSeek USD** を記録する（詳細は `logs/res23/README.md`）。期間中は日次上限を設けない。`dsh-sub` は消さない（契約前・枠切れの控え）。期間後は RES-23 の結果を見て本人が方針を決める。
31: - **Composer / Grok は原則使わない**（ローカルの W1 は `codex-sub`。§2.5）。
32: - **例外（3つ）** — いずれも **Grok / Composer は Fast オフを明示**（本ファイル §2.1 の Fast 手順、`docs/routing.md` §8）:
33:   - **機密（Flag: Private）**: **Composer 2.5**（`fastMode: false` を明示した T3 / 非 Fast CLI）。
36: - **Composer / Grok は申請不要。ただし Fast オフを明示した呼び出しに限る**（下記）。Fable は Other Models 専用・要許可。Opus 5.5 を Cursor で呼ぶのは禁止（`claude` を使う）。
37: - **Cursor モデル（Composer / Grok）は Fast を使わない**。T3 `delegate_task` は options 無しだと Fast で動く（2026-10-23 にダッシュボードで確認。UI は Fast オフと表示するが信用しない）。`target.options` に `fastMode: false` を**必ず**明示し、応答の `options` で確認する。CLI は `-fast` 無しの ID。明示せずに呼んだ場合は申請不要の範囲外（無許可の Fast 利用）として扱う。詳細は `docs/routing.md` §8 および `rules/delegation.md` §8。
44: - **設計**: Grok 4.7（**必ず非 Fast**）
45: - **実装**: Composer 2.5（**必ず非 Fast**）
61: - **ループ最初に 1 回**: Opus が方向・仕様の骨子・完了条件（DoD）を決める（§3.6 **申請不要**）。
62: - **細かい仕様・実装・軽いセルフレビュー**: **Codex**（`codex-sub`、ChatGPT ログイン・effort medium）。スキル `codex-harness`。
63: - **Opus 5.5 へ上げる**: 同一タスク内で前提が崩れたとき、または**同じ指摘が 2 回**出たとき（§3.6 **申請不要**）。
70:     - **第一候補**: T3 ネイティブ委譲 `delegate_task`（`providerInstanceId: "codex"`, `model: "gpt-6.1-sol"`）を優先使用する。
71:     - **設定**: `target.options` に `{"reasoningEffort": "medium", "serviceTier": "default"}` を指定（Fast 禁止）。
72:     - **フォールバック**: Codex 利用上限時・エラー時は、オーケストレーターが `delegate_task`（`opencode/deepseek-v4.1-flash-free` または `deepseek` プロバイダ）へフォールバックする。
74:     - **第一候補**: CLI ラッパー `codex-sub --repo <dir> --prompt "..."`（ChatGPT Plus ログイン、effort medium）。
75:     - **フォールバック**: `codex-sub` 内部の自動判定により、上限時・未ログイン時は自動的に `dsh-sub`（DeepSeek API）へフォールバックする。スキル `codex-harness`。
76: - **モデル系統**:
77:   - ChatGPT Plus の主力は **`gpt-6.1-sol` / `gpt-6.1-terra` / `gpt-6-luna`**（`gpt-6-astra` は Plus には付帯しない）。
78:   - `codex-sub` ではモデル名を引数に固定せず、ChatGPT Plus ログインアカウントの既定（6.1 系列）に任せる。
79:   - T3 Code のネイティブ委譲では、`gpt-6.1-sol` を既定とする。
80: - **代替（控え）**: `codex` が無い・未ログイン・API キー認証・利用上限のとき **`dsh-sub`**（T3 では DeepSeek 委譲、CLI では `codex-sub` が自動フォールバック）。
86: - **T1・T2・T3**: 当面**呼ばない**。Codex のセルフレビューは Maker の報告であり Breaker ではない。
87: - **Breaker**: 大きなループの**最後に Opus 5.5 を 1 回**（§3.6 申請不要）。**引き上げ**（前提崩れ・同指摘 2 回）も Opus 5.5。
88: - Maker が `dsh-sub`（フォールバック）のときも **T1 を `dsh-sub` にしない**（同系統の二重チェックを避ける）。
93: - **控え**（W1 フォールバック・明示 `dsh-sub` 指定時）。`bin/dsh-sub` は残す。既定 `deepseek-flash` / effort `high`。難所は `deepseek-v4-pro` / `effort max`（常用禁止）。無料枠と混同しない。Auto-reload は OFF。呼び出し契約はスキル `deepseek-harness`。
97: - **大きなループの終わり**、人が読む文章に使う。担当モデルは **Gemini 3.8 Flash**（agy）。
110: - **モデル別の置き場所**: **Sonnet 5.5** は既定経路から外す。**名指し**（agy / Team）のときだけ使う。**Opus 5.5 は Team 優先**（オーケストレーター・ループ頭尾の設計/レビュー）、agy は週枠が余っているときだけ（事前許可制）。
117: ## 3.5 effort の既定値
119: - 既定は **medium**。high は「成功条件が開いている」案件だけに使う。
120: - 閉じている（ルーブリック・DoD・テスト・差分がある）: medium。
121: - 開いている（何が良いか自体を決める）: high。
122: - 機械的（整形・分類・抽出）: low。
123: - モデルと effort は別軸。モデルを上げる前に effort を下げられないか考える。
124: - **役割の目安**: ループ頭の設計 = Opus 5.5 high（§3.6 申請不要）/ 細部・W1・セルフレビュー = Codex（`codex-sub`）/ 控え = `dsh-sub` / Cloud 実装 = Composer 2.5 / 敵対レビュー = ループ末 Opus 5.5 のみ / Flash = W2・Extract・整形・Visual QA 第一候補（yomiyasu は §2.8 のみ）。ローカル Grok 4.7 = Visual QA フォールバック・Opus 不在時の司令塔代行のみ（§2.1）。
125: - **effort を変えるときは新しいスレッドで始める**。同一スレッドの途中で変えると、それまでの履歴を読み直すうえキャッシュも効きにくい（Antigravity の運用知見）。
126: - medium と high の品質差は小さいという報告が複数ある。差の有無は**モック実験ではなく普段の使用感**（返答の質・トークンの減り方）で判断する（2026-10-21 決定）。
128: | provider | 無指定のときの effort | 対処 |
130: | claudeAgent の Sonnet | **high** | `options` で medium を明示する |
131: | claudeAgent の Opus / Fable | medium | 明示不要。high にするときだけ書く |
132: | antigravity の Argon | モデル ID で決まる | `gemini-4-argon-medium` を既定にする。high は明示的な判断としてのみ |
136: - 呼び出し前の申請は **ファミリーと effort の格上げ** だけ。5h / 週枠の消費％を推定して申請しない。
137: - **オーケストレーターのハンドオフ**（`rules/delegation.md` §1）: 司令塔が `docs/routing.md` に従い Worker（W1 `codex-sub` 等）・探索・レビュアへ `delegate_task` / CLI で委譲するのは**本人が許可済み**。都度の申請は不要。
138: - **要申請**: Fable 5.1 / Sonnet 5.5 の high / Argon high（格上げ、3.7）/ Anthropic・OpenAI の従量 API / **OpenAI 従量での Codex** / **Opus 5.5 のうち、下記「申請不要」に該当しない用途**（例: Phase-First の節目 Opus 5.5、発想・裁定のみの追加 Opus 5.5、agy 週枠の Opus 5.5）。
139: - **申請不要**: Composer / Grok（`fastMode: false` を明示した場合のみ。§2）/ Gemini 3.8 Flash / Argon medium / Sonnet 5.5 (medium)（**名指し時**）/ DeepSeek Free / **W1 の Codex（ChatGPT ログイン、T3 `delegate_task` または `codex-sub`）** / **W1 の DeepSeek / `dsh-sub`（フォールバック・明示指定）** / **Opus 5.5 の次の用途**:
142:   - 同一タスク内で前提が崩れたとき、または同じ指摘が 2 回出たときの、**Codex（フォールバック時は `dsh-sub`）から Opus 5.5 への引き上げ**
143: - **依頼者がモデル/effort を名指しした場合は、その1回分の許可とみなす**（提案も再確認も不要。例:「Argon high で設計して」）。
145: ## 3.7 格上げの提案（名指しされたモデルは勝手に変えない）
147: - 名指しされたモデル/effort でも、成功条件が開いている（設計判断・前提の崩壊・論文の主張）と分かっていれば、**着手前に1行**で格上げ案を出す。
148: - **出力が格上げ後に再利用できない作業**（判断・主張の組み立て）は、承認が出るまで開始しない。**例外**: §3.6 申請不要の Opus 引き上げ（前提崩れ・同指摘 2 回）と、申請不要のループ頭設計・ループ末レビュー。再利用できる作業（調査・列挙・材料集め）は medium で進めてよい。
150: - 格上げ先の順序: ①同一モデルの effort 上げ（要許可）②前提崩れ・同指摘2回は **Opus 5.5**（§3.6 申請不要。Sonnet 5.5 high より優先）③別ファミリー medium ④Fable（核ボタン・要許可）。**要申請の格上げ先は、承認が出るまで切り替えない。**
151: - 名指しモデルの変更は承認があったときだけ（Strict Model Fidelity）。「任せる」と言われた場合はこの限りでない。
156: - 意地悪テスト生成・敵対的監査は「Maker-Breaker原則（実装と検証は異種モデル・コンテキスト完全隔離）」を遵守すること。**Maker** は Codex（`codex-sub`、フォールバック時は DeepSeek **`dsh-sub`**）。**Breaker** はループ末の **Opus 5.5**（T1/T2/T3 は当面なし。**Gemini 3.8 Flash は敵対レビューに使わない**）。選定と詳細手順はスキル `adversarial-review` および `model-route` を参照。
160: - 共通手順は `agents/skills/typst-workflow/SKILL.md` を各エージェントが明示readする。
161: - 論旨・主張・章立ては **Opus**。確定材料からの本文下書き/修正・図表・体裁・テンプレ移植は **Codex medium**。
163: - PNG目視は **Flash → Grok（画像判断能力は未確認）**。同じ問題が2回なら **Opus**。ループ末は **Opusの独立review**（Makerの自己確認とは別）。
164: - T3では `delegate_task` のcodexが基本。`target.options` は `{"serviceTier": "default", "reasoningEffort": "medium"}`。CLI `codex-sub` は非T3の補助経路。
165: - **全Fast/priority禁止**。Claude/Cursorは `target.options.fastMode: false` を明示し、Codexを含め応答の `options` を確認する。GeminiはFast off設定が公開されていないため、勝手なoptionsを発明・実行しない。確認できない場合は停止して報告する。
166: - タスクでAPI禁止なら `dsh-sub` 自動fallbackのあるラッパーを使わず停止する。再委譲はそのタスクで許可されたモデルのみ。CLI AI/追加委譲禁止も優先し、独立reviewを勝手に実行しない。
```

### `docs/routing.md`

```text
1: # モデルルーティング表（2026-11-01）
3: > 方針・禁止事項は `agents/rules/models.md` が正本。本書は「タスク → モデル」の対応表。
11: 2. **Phase-First Override**: 教員報告前・数理難所・章立て・仕様策定の山場なら、**Opus 5.5**（`models.md` §3.6 **要申請**、ループ頭設計と別）を投入する。Sonnet 5.5 (medium) は**名指しのときだけ**。Argon は設計に使わない。モデルと effort は別軸（`rules/models.md` §3.5）。
14: 5. **チャネル**: `in agy` / `in claude` / `codex-sub` / `dsh-sub`（明示 DeepSeek）/ `in cursor`（例外のみ）の指定を確認。省略時は下のフォールバック順。
21: | **Design（ループ頭）** | 方向・骨子・DoD | `claude: Opus 5.5`（high・`models.md` §3.6 申請不要） | — |
22: | **Design（細部）** | 仕様・疑似コード | `codex-sub`（effort medium） | 契約前・枠切れは `dsh-sub` |
23: | **Design（発想）** | アイデア・問いの立て直し | `agy: Gemini 4 Argon` (medium) | Web Argon |
24: | **Implement（中段）** | 打鍵・実装・リファクタ（W1） | `codex-sub` | `dsh-sub`（フォールバック） |
25: | **Implement（後段）** | Diff 敵対監査 | T1/T2/T3 なし | ループ末 Opus 5.5（`models.md` §3.6 申請不要） |
27: | **Flag: Private** | 機密・生活メモ・認証情報 | `cursor: Composer 2.5`（非 Fast） | `claude`（Team） |
32: ## 3. 役割別モデル（ローカル）
37: | 設計（ループ最初の 1 回） | Opus 5.5（high・`models.md` §3.6 申請不要） | — | claudeAgent / `claude` |
38: | 細かい仕様 | `codex-sub` | `dsh-sub` | CLI / T3 |
39: | 発想のみ | Gemini 4 Argon (medium) | Web Argon | agy |
41: | ループ最後のレビュー | Opus 5.5（1 回・`models.md` §3.6 申請不要） | — | claudeAgent |
42: | 実装ループ（W1） | **Codex（`gpt-6.1-sol` / `codex-sub`）** | **DeepSeek / `dsh-sub`**（控え） | T3（`delegate_task`） / CLI（`codex-sub`） |
45: | Visual QA フォールバック / Opus 不在時の司令塔代行 | Grok 4.7（Cursor・非 Fast） | — | cursor / T3 |
48: - **Codex W1 の実行チャネル（環境による分岐）**:
49:   - **T3 Code 環境（`delegate_task` 利用可能時）**: T3 ネイティブ委譲 `delegate_task`（`providerInstanceId: "codex"`, `model: "gpt-6.1-sol"`, options: `{"reasoningEffort": "medium", "serviceTier": "default"}`）を使用。上限・エラー時は DeepSeek 委譲へフォールバック。
50:   - **非 T3 Code 環境（Claude Desktop Code モード / Cursor / 端末 CLI）**: CLI ラッパー `codex-sub`（ChatGPT Plus 枠、effort medium）を使用。上限時は内部で自動 `dsh-sub` フォールバック。
51: - effort は既定 **medium**。high は「何が良いか自体を決める」案件だけ（`rules/models.md` §3.5）。
52: - 前提崩れ・同じ指摘 2 回 → **Sonnet 5.5 high ではなく Opus 5.5** へ。回数と理由を記録（RES-23 と合わせて分析）。
56: | 役割 | モデル | Fast |
65: | **W1 日常実装** | **`codex-sub`** | `dsh-sub`（契約前・枠切れ・明示 DeepSeek） | 編集 → テスト → 修正 |
74: 成果物の合否が「見て決まる」仕事（matplotlib の論文図、凡例、キャプション、HTML の重なり）は、スクリプト実装と目視を分ける。Task 列に Visual は足さない。画像生成モデルも経路に入れない。Composer を図禁止にもしない。
76: - **スクリプト・数値・フォント・再現性**: W1（`codex-sub` / フォールバック `dsh-sub`）。ここは閉じた Implement。
77: - **PNG / 画面の目視**: W1 の自己申告は証拠にしない。**第一候補は Gemini 3.8 Flash**（agy・マルチモーダル）。**フォールバックは Grok 4.7**（Cursor・非 Fast）。Grok 4.7 がローカルで PNG をどこまで判断できるかは**未確認**（試す前に期待値を上げない）。DeepSeek / Composer に「PNG を見て重なりなしと報告せよ」とだけ頼まない。**通常の Visual QA に Opus 5.5 は使わない**（引き上げ時のみ `models.md` §3.6）。
86: - **Fast は使わない**（`rules/models.md` §2.1、`rules/delegation.md` §8、`docs/routing.md` §8）。T3 `delegate_task` は `fastMode: false` 必須。
87: - Maker-Breaker: Maker は Codex（フォールバック DeepSeek）。Breaker は **ループ末 Opus 5.5** のみ。
98: | `w1 in codex` | ChatGPT Plus（Codex CLI） | `codex-sub --repo … --prompt …`（スキル `codex-harness`） |
100: | `flash in agy` | Google AI Pro（Gemini 枠） | 探索・Search・W2・Extract・整形・Visual QA・yomiyasu（推敲）。`gemini-3.8-flash-high` / `agy` |
101: | `argon in agy` | Argon 独立週枠 | **発想のみ** `gemini-4-argon-medium` |
102: | `sonnet in agy` | Google AI Pro（Claude 週枠） | `agy --model claude-sonnet-5-5-medium` |
104: | `composer in cursor` | Cursor Pro | **Private のみ**（非 Fast 明示） |
105: | `grok in cursor` | Cursor Pro | Visual QA フォールバック・Opus 不在時の司令塔代行（非 Fast）。Cloud 設計は Cloud Agent 経路 |
108: | `cloud design` | Cursor Cloud | Grok 4.7 非 Fast |
109: | `cloud implement` | Cursor Cloud | Composer 2.5 非 Fast |
111: **モデル→プロバイダは固定**（カタログに出ていても、契約が違うプロバイダでは選ばない）
113: | モデル | 使うプロバイダ | 選ばない先 |
115: | W1 Codex | `codex-sub` | API キー Codex・Private への Codex は禁止 |
127: - **設計**: Opus 5.5（ループ頭 1 回）→ Codex（細部）→ 前提崩れ・同指摘 2 回で Opus 5.5。
128: - **実装（W1）**: `codex-sub`（無ければ `dsh-sub`）。
136: | モデル | 役割 | 設定 | 原則 |
138: | Opus 5.5 | オーケストレーター・ループ頭の設計・ループ末レビュー・**裁定** | `effort: high` | ループ頭/末・引き上げは `models.md` §3.6 申請不要。**裁定のみ等は要申請** |
139: | Sonnet 5.5 | 名指し時のみ（細仕様・旧 W3 等） | `effort: medium` | 既定経路からは外す |
140: | Fable 5.1 | 特別顧問 | `effort: high` | 日常禁止。軸崩壊時のみ |
141: | Haiku 5.5 | 配管（非推奨） | `effort: low` | 探索は Gemini 3.8 Flash |
147: - 同じ指摘が 2 回続く / 設計の前提が崩れた → **Opus 5.5**（Sonnet 5.5 high より優先。**`models.md` §3.6 申請不要**）
154: - 仕様が固まり、実装が機械的（W1 `codex-sub` / フォールバック `dsh-sub`）
156: - 同じモデルで 2 回連続して新しい指摘が出ない
166: - **計測期間 RES-23（〜2026-11-07）**: `rules/models.md` §0 と同じ 5 系統（Codex 残・Codex タスク・Opus 差戻・Claude Team・Cursor・Gemini・DeepSeek USD）。`logs/res23/README.md`。
176: - **Codex を API キー（`OPENAI_API_KEY`）で呼ぶ**。
177: - **Private タスクを Codex に出す**。
178: - **Codex の Fast を使う**。
179: - 指定モデルを勝手に昇格・降格する。
182: - **Cursor の Fast を使う**（Cloud / Private / Grok 例外でも off 明示）。
184: ### Grok / Composer の Fast ガード（T3・CLI）
186: - T3 `delegate_task` で Cursor モデルを呼ぶとき `target.options` に `{"fastMode": false}` を**必ず**明示。応答の `options` で確認。
187: - CLI は `-fast` 付き ID を使わない。`cursor-agent --list-models` / `~/.cursor/cli-config.json` の `fast: false` を参照（`rules/delegation.md` §8）。
193: **2026-11-01**: RES-23 に合わせ W1 の第一候補を **Codex（`codex-sub`）** に移行。契約前・枠切れは **`dsh-sub` 控え**。T2 の Sonnet 敵対レビューは停止（Breaker はループ末 Opus のみ）。
195: ## Typstの分担（共通workflow）
200: | 確定材料から本文下書き/修正・図表・体裁・テンプレ移植 | Codex medium |
205: 各担当は `agents/skills/typst-workflow/SKILL.md` を明示readする。T3は `delegate_task` codex（`target.options: {"serviceTier": "default", "reasoningEffort": "medium"}`）が基本、CLI `codex-sub` は非T3補助。全Fast/priority禁止、Claude/Cursorは `fastMode: false` を明示し応答options確認。Geminiの未公開Fast off optionsは発明・実行しない。API禁止時は `dsh-sub` 自動fallbackを使わず停止、再委譲は許可されたモデルのみ（詳細: `rules/models.md`「Typst」）。
```

### `skills/model-route/SKILL.md`

```text
3: description: "タスク内容や質問に応じて、最適な AI モデル（Opus / Codex / codex-sub / dsh-sub / Flash / Grok 等）の選定・ルーティング、Thinking レベルを即答判定する。「should we use argon?」「これOpus使うべき？」「どのモデルで回すべき？」「モデルルーティング」「モデル判定」「model route」で発動。"
8: タスクに最適なモデル・実行環境・思考深度を即答する**手順書**。
9: モデルの事実は持たない。方針は `rules/models.md`、対応表は `docs/routing.md` を読む。
19:    - Cloud → 設計 **Grok 4.7**、実装 **Composer 2.5**（いずれも非 Fast）。`routing.md` §3 Cloud Agent。
21:    → Yes なら **Opus 5.5**（`models.md` §3.6 **要申請**。ループ頭設計と別）または Sonnet 5.5 (medium)（名指し時）。Argon は設計に使わない。
23:    - Design（大きなループ）: 頭 1 回 **Opus 5.5**（方向・DoD）→ 細部 **Codex（`codex-sub`）**。
24:    - Implement（W1）: ローカルは **Codex**。**Private** は Codex に出さず **Composer 2.5**（非 Fast）。
25:      - **T3 Code 環境（`delegate_task` 利用可能時）**: T3 ネイティブ委譲 `delegate_task`（`providerInstanceId: "codex"`, `model: "gpt-6.1-sol"`, `serviceTier: "default"`, effort: medium）を使用。Codex 上限時は `delegate_task` で DeepSeek へ切り替え。
26:      - **非 T3 Code 環境（Claude Desktop Code モード / Cursor / 端末 CLI）**: CLI ラッパー **`codex-sub`** を実行。
27:        `codex-sub` が **`dsh-sub` へ自動フォールバック**するのは次のとき:
28:        `codex` CLI が無い / 未ログイン / API キー認証 / 利用上限 /
29:        `~/.codex/config.toml` で Fast 有効 / exec タイムアウト（スキル `codex-harness`）。
31:    - 敵対レビュー: **T1/T2/T3 なし**。Breaker は**ループ末 Opus 5.5** のみ（§3.6 申請不要）。
33:     → Yes なら W1 は `codex-sub` のまま、目視 QA は **Gemini 3.8 Flash** → フォールバック **Grok 4.7**（Cursor・非 Fast。PNG 能力は未確認）。2 回目は **Opus 5.5 引き上げ**（`routing.md` §3 Visual QA）。
35:    - Private → **Composer 2.5**（Cursor・非 Fast）。**Codex に出さない**。
39: 5. **Grok 4.7（ローカル）**: **Visual QA フォールバック**または **Opus 不在時の司令塔代行**のみ。Fast は使わない（`docs/routing.md` §8）。
40: 6. **環境指定**: `in agy` / `in claude` / `codex-sub` / `dsh-sub` / `in cursor`（例外のみ）。
42: 7. **昇格**: 前提崩れ・同指摘 2 回 → **Opus 5.5**（`models.md` §3.6 **申請不要**）。回数と理由を記録（RES-23）。
44: **やらないこと**: 残量ペースでモデルを動的に切り替える（旧手順 5 を廃止）。必要なら `update-ai-usage` で使い切り防止のみ確認する。
49: ### 🎯 モデル選定判定
50: - **推奨モデル**: `codex-sub`（W1） / `claude: Opus 5.5`（オーケストレーター） 等
51: - **effort**: medium（Codex W1・`codex-sub` 既定。ループ頭/末 Opus は `models.md` §3.6 申請不要）
54: - **記録**: RES-23 中は Codex 残・Codex タスク・Opus 差戻・Claude Team 残量等（`logs/res23/README.md`）
59: - 参照ファイルに無いモデル・数値・slug を発明しない。
61: - 指定モデルを勝手に昇格・降格しない（Strict Model Fidelity）。
63: - **API キーの Codex** / **Private への Codex**。
66: - Maker が Codex のあいだ **Sonnet / `dsh-sub` を Breaker にしない**（ループ末 Opus のみ）。
70: 共通作業前に `../typst-workflow/SKILL.md` を明示read。論旨・主張・章立て=Opus、確定材料から本文下書き/修正・図表・体裁・テンプレ移植=Codex medium、推敲=Flash+yomiyasu本体（意味・数値・引用diff）、PNG目視=Flash→Grok（能力未確認）・同問題2回=Opus、ループ末独立review=Opus。
71: T3では `delegate_task` codexを基本に `target.options: {"serviceTier": "default", "reasoningEffort": "medium"}`、CLI `codex-sub` は非T3補助。全Fast/priority禁止、Claude/Cursorは `fastMode: false` と応答options確認。Geminiの未公開Fast off設定は発明・実行しない。API禁止時は `dsh-sub` 自動fallbackを使わず停止し、再委譲は許可されたモデルのみ。タスク固有のCLI AI/追加委譲禁止を優先する（`models.md`「Typst」）。
```

### `skills/codex-harness/SKILL.md`

```text
2: name: codex-harness
3: description: "Codex CLI を CLI サブエージェントとして呼び出す契約。codex-sub の引数・Codex exec フラグ・ChatGPT 認証・dsh-sub フォールバック・返却 JSON・exit code、W1 向け禁止事項を扱う。「Codexで実装」「codex-sub で」「W1 Codex」で発動。"
6: # codex-harness (`codex-sub`)
8: オーケストレータから **Codex CLI（ChatGPT Plus ログイン）** を W1 ワンショットサブエージェントとして呼ぶ契約。
9: `codex` が無い・未ログイン・API キー認証・利用上限のときは **同じ引数で `dsh-sub` にフォールバック**する（散文のフォールバック指示は読み飛ばされるためラッパーが実行する）。
14: codex-sub --repo /path/to/repo --prompt "タスク本文"
15: codex-sub --repo . --prompt -
20: | `--repo <dir>` | 必須。`codex exec --cd` / 子 cwd |
22: | `--timeout <sec>` | 既定 900。Codex 超過時と dsh-sub 呼び出しの両方に渡す |
24: ## Codex exec（成功経路）
26: モデル名は付けない。`preferred_auth_method` 等の削除済み `-c` は**付けない**（未知キーで exec 全体が失敗しうる）。
29: codex exec --json --cd "$repo" \
31:   -c 'model_reasoning_effort="medium"' \
35: 子プロセスの環境から **`OPENAI_API_KEY` / `CODEX_API_KEY` を除去**する（シェルにキーが残っていても ChatGPT ログインを優先）。
37: **Fast**: exec 引数では切らない。実行前に `~/.codex/config.toml` を読み、`service_tier = "fast"` または `[features] fast_mode = true` なら **exec せず dsh-sub**（理由を `reason` に書く）。契約後に `[features] fast_mode = false` 等を本人マシンで確認すること。
39: **使わない**: `--dangerously-bypass-approvals-and-sandbox` / `--approve-for-me` / `--full-auto` / 明示的モデル ID / Fast tier。
43: 1. `command -v codex` 失敗
44: 2. `codex login status` が 0 以外
46: 4. stderr または JSONL の**エラー種イベント**に `You've` / `You\u2019ve hit your usage limit` または `usage limit reached`（**モデル本文の stdout では判定しない**）
47: 5. `~/.codex/config.toml` で Fast が有効
48: 6. 本人が「今日は Codex を止める」と明示
56: 成功（Codex）:
59: {"ok":true,"provider":"codex","text":"…","session":"thread-…"}
66:  "reason":"codex binary not found","text":"…","sessionId":"…"}
84: Codex 成功経路と **dsh-sub フォールバック**の両方で、返答に次を義務づける:
90: - **Codex Fast**（config で有効なら exec 前にフォールバック）
91: - **Private タスクを Codex に出す**（Private は Composer 2.5）
92: - ネットワーク必須・ワークスペース外操作を Codex に期待する（workspace-write の範囲外）
96: - **T3 Code 環境（`delegate_task` 利用可能時）**: 司令塔（Opus 等）から `delegate_task`（`providerInstanceId: "codex"`, `model: "gpt-6.1-sol"`, `serviceTier: "default"`）で直接委譲する。UI での追跡・ワークツリー機能との統合を最優先とする。
97: - **非 T3 Code 環境（Claude Desktop Code モード / Cursor / 端末 CLI、本スキル）**: CLI ラッパー `codex-sub` を経由して `codex exec` を呼び出し、利用枠判定と `dsh-sub` 自動フォールバックを活用する。
```

### `GLOBAL_RULES.md`

```text
9: - **高額 API**: 明示指示なしに Anthropic / OpenAI の従量 API を使わない。サブスク枠を優先する。**ChatGPT Plus の Codex** は `codex login` のサブスク枠。**`OPENAI_API_KEY` での Codex** は従量なので、明示指示があるときだけ。→ `rules/models.md`
11: - **Cursor の Fast（2 倍課金）**: Composer / Grok を T3 `delegate_task` で呼ぶときは `target.options` に `{"fastMode": false}` を必ず明示し、応答の `options` で確認する。未指定は Fast で動く（T3 の UI は Fast オフと表示するが信用しない）。既存スレッドへの追補は先に `t3_thread_configure`。CLI は `-fast` 付き ID を使わない。→ `rules/delegation.md` §8
16: - 実装と検証は異種モデル・別コンテキストで行う（Maker-Breaker）。
17: - 指定されたモデルを勝手に昇格・降格しない（Strict Model Fidelity）。
43: | モデル選択・クォータ・敵対レビュー | `rules/models.md` |
```

## 意味を変える箇所と理由

- rules/models.md §2.5: Sol 固定を作業別選択へ変更し、確定実装を Terra に寄せて Sol の消費を減らす。GPT 内の孫委譲を許し、利用可能性・設定報告・タスク固有制約を明記する。
- rules/models.md §3.5–3.6: T3 Codex 子は機械的作業でも medium を既定とし、high の割当表が事前申請を省略する意味にならないよう明記する。
- docs/routing.md §3: Codex 作業別割当は models.md §2.5 へ参照を一本化する。既存 CLI のモデル無指定・medium 契約は変えない。
- model-route: 下記の再評価に基づき、具体モデル・分担・設定・fallback条件の複写を除き、判定手順と参照・回答に絞る。codex-harness の T3 節も正本参照へ変更する。
- rules/delegation.md §8: 指定5ファイル外にも残る T3 の1行を正本参照へ直し、モデル・options の複写をなくす。

## 整合性と人間の判断

- Strict Model Fidelity: 名指しを優先し、未提供モデルへの無断代替を許さない。
- Maker-Breaker: GPT の孫は探索・機械作業用であり、独立 Breaker の代用ではない。既定のループ末 Opus を維持。
- Cursor Fast と HPC: 既存禁止を変更せず、孫にも継承させる。
- 既存の T3 エラー時 DeepSeek フォールバック記述は今回変更しない。ただし、このタスクの GPT 限定や実行環境の無断代替禁止が優先する。
- 設計・計画の Sol high は Codex に割り当てた作業内の選択。ループ頭 Opus や Phase-First の役割は変更しない。
- Argon 案は以下の1項目を採用するか人間が決める。対象範囲・終了日は未指定なので発明しない。

## 初回の別案：Argon 監査（履歴。現行案は末尾の解消結果）

確認した規則・routing・adversarial-review に暫定運用は見当たらない。以下は rules/models.md §2.5「敵対的レビュー」末尾へ追加する独立案。

```diff
--- a/agents/rules/models.md
+++ b/agents/rules/models.md
@@ 「敵対的レビュー」末尾に追加（位置指定の擬似 diff） @@
+- **暫定・人間の指示（2026-11-04）**: Claude の枠を節約するため、当面の監査は Argon（antigravity、medium）へ回す。この暫定監査に限り「Breaker はループ末 Opus のみ」「Argon は発想のみ」の例外とする。Maker と異なるモデル・別コンテキストで行い、設計・仕様・実装への利用は許可しない。high への格上げは §3.6–3.7 に従う。
```

意味変更の理由: 人間が指定した節約のための暫定監査を、恒久的な役割変更と区別する。採用時は routing・adversarial-review 等の「Opus のみ／発想のみ」からこの例外への参照も同期する。

## 変更の層と取り消し

- 層: Context（規則・対応表・手順の参照）。
- 不要: 実装ハーネス、Loop、Graph、CLI の変更。
- 取り消し: 今回の対象ファイルの差分だけを逆適用する。他スレッドの差分は戻さない。

## Argon・Grok の意見を受けた再判断（第2案の履歴）

- 共通意見: 問題は71行の長さより、同じ契約・割当が4〜5ファイルに複製されていること。課金・機密・権限の境界はモデル更新でも消えない。
- 意見の相違: Argon は Codex 割当表を routing に、Grok は models に残す案。今回は方針正本 models.md §2.5 の表を唯一の定義とし、routing は参照する。初回案の二重表は撤回した。
- 両者の短縮案も具体モデルと禁止一覧を再掲していたため、そのまま採用せず、model-route は判定の観点・参照先・回答内容だけに整理した。境界の確認項目は残す。
- API禁止・モデル固定と自動fallbackの衝突は、実行前に許可範囲を確認する手順として残した。モデル名指しだけを理由に既存の許可済みfallbackを一律禁止する新規方針にはしない。
- 他スキルの一括整理は行わない。codex-harness の引数・キー除去・Fast検査・JSON契約等の固有仕様、typst-workflow、GLOBAL_RULES、HPC規則は維持する。
- 次の棚卸候補: routing の Typst/禁止/履歴の複写、期限後の RES-23 記述。今回は変更しない。新しい棚卸専用スキル・自動ループは作らない。

### 第2案時点の未解決の既存矛盾（末尾で解消）

models.md §2.5 の T3 fallback は opencode/deepseek-v4.1-flash-free を含むが、同節は Free を W1 代替にしないとも規定する。初回報告はこの既存矛盾を見落としていた。配置整理でどちらかを採用せず保留する。モデル・プロバイダが指定された実行では、上位のツール契約とタスク制約を優先し、未許可の代替は行わない。

### レビューの実行設定

- Argon: antigravity / gemini-4-argon / thinking_level: medium。
- Grok: cursor / grok-4.7 / reasoning_effort: medium / fastMode: false。
- 上記は親の delegate_task 応答 options で確認。子の自己申告では設定を確認できていない旨があったため、自己申告から推測せず親側の記録に基づく。
- 両者とも読み取りのみ。画像の趣旨は brief に文章で伝えた。レビュー後の改訂案を再監査したという意味ではない。

## 通常ルートの照合と矛盾の解消（最新案）

これは文書・参照先の手動照合であり、各モデルを実際に起動する振る舞いテストではない。整理前の model-route と、その参照先の現行規則を比較した。

| 依頼・条件 | 整理後の判断と参照 | 整理による意図しない変更 |
|---|---|---|
| T3で仕様確定の生成器・テスト実装 | models §2.5: Terra medium、default tier | なし。当初の人間指定による意図的変更 |
| T3で既存データのスクリプト解析 | models §2.5: Sol medium | なし |
| T3で設計・計画・解釈が分かれる解析 | models §2.5: Sol high、§3.6–3.7で事前申請 | 当初の人間指定による意図的変更。CLI mediumとは区別 |
| 非T3の通常W1 | codex-sub、モデル無指定・medium | なし |
| Private の実装 | routing §2: Composer 非Fast、Codex/agy禁止 | なし |
| Cursor Cloud | routing §3: 設計Grok／実装Composer、非Fast | なし |
| Search・Extract・W2・ログ整形 | routing §2–§3: Flash | なし。既存データの解析とログ整形を混同しない |
| Visual QA | routing §3: Flash→Grok、同問題2回でOpus | なし |
| 人が読む日本語推敲 | routing §3: yomiyasu本体＋Flash | なし |
| ループ頭の方向・DoD／Phase-First | Opus。前者は申請不要、後者は要申請 | なし |
| 前提崩れ・同指摘2回 | models §3.6: Opusへ引き上げ、申請不要 | なし。Argon暫定監査とは別 |
| ループ末の独立監査 | models §2.5「暫定監査」: Argon medium | 人間の2026-11-04指示による意図的変更 |
| 名指し・API禁止・GPT限定・追加委譲禁止 | model-route 判定1・実行時参照、models §2.5: 制約に適合しないfallbackを使わない | 境界を一般節にも明記。許可済みDeepSeekを一律禁止しない |
| HPC | hpc規則・クラスタスキル。生コマンド禁止 | なし |

### 解消した点と理由

1. **Free の W1 fallback**: models §2.5 の候補から Free を外した。既存の同節・routing §4の「W1に使わない」に統一。新たな課金契約は追加していない。
2. **fallback と Fidelity/API禁止**: 一般のW1 DeepSeek許可は維持し、タスクと実行環境の禁止を優先する境界を models §2.5 に明記。API禁止の安全弁がTypstだけに隠れる状態を解消。
3. **medium と high**: T3は作業別表、CLIは既存medium契約を参照。high承認時もdefault tierを維持。「細かい仕様は常にmedium」という旧文をチャネル別に修正。
4. **Argon 暫定監査**: 人間の「矛盾・未解決を解決したい」という指示を受け、当初別案を規則の差分案へ取り込んだ。正本に例外を1か所定義し、routing・delegation・cursorrules・adversarial-review・update-agent-configから参照。監査以外の設計やOpus引き上げは維持し、未提供時の無断代替はしない。
5. **Argon T3/CLI設定**: 現行ライブカタログでT3はモデルIDとthinking_levelが別だったため、古い「モデルIDだけでeffortが決まる」をT3の公開設定／CLIのIDに分けた。未公開Fastオプションは作らない。

### 追加で編集したファイル

- rules/cursorrules: Argon用途とBreakerの要約を正本参照へ変更。
- skills/adversarial-review/SKILL.md: 暫定指示の優先を入口と実行手順へ反映。独立性・read-onlyを維持。
- skills/update-agent-config/SKILL.md: 監査モデル固定の表を正本参照へ変更。

層はContextのみ。Loop・Graph・CLI実装の変更は不要。取り消す場合は今回の対象差分だけを逆適用し、他スレッドのautohotkey差分を保護する。

追記: delegation §3 の「別モデルのFree指定をinherit相当とする」例も削除し、ライブカタログから実モデル・設定を選ぶ記述へ変更。routing の曖昧な「公式API禁止」は既存の Anthropic/OpenAI 従量禁止と DeepSeek許可を区別して明確化した。

検証: 対象差分の `git diff --check` 通過。参照先と上表の代表経路を手動照合。quick_validate は前回 PyYAML 未導入で実行できておらず、実モデルを起動する回帰試験は実施していない。

## 追加の人間指定（最新・2026-11-04）

- DeepSeek Free は W1/W2 とも使わない。API は dsh-sub 必須タスク、または枠不足で人間が明示した場合だけ。先の「既存の広いfallback許可を維持」はこの指定で置き換える。
- 現在の codex-sub は API 自動切替を止めるオプションを持たないため、API 切替まで許可されていないタスクでは使わないと入口に明記。bin の実装は変更していない。CLI の Codex-only 経路を整備するなら別の実装課題となる。
- 非研究リポジトリの司令塔は、本人の現運用に合わせ Grok（非Fast）または Gemini Flash。既存の研究向けOpus既定との適用範囲を区別する。Private・API・HPCなどの境界は維持。
- Argon low の用途拡大、GCPクレジット経路の追加は提案段階。既存のantigravity固定はまだ変更していない。残高70ドルはユーザー申告で、正本に残高を固定しない。
- 今回追加で deepseek-harness の冒頭も正本参照へ変更した。実行コマンド・キー・課金設定は変更していない。

## Codex-only実装とGoogle API事前許可（最新）

- 人間の①許可により bin/codex-sub から dsh-sub の起動処理を削除。起動不能・API認証・Fast設定・利用上限・実行失敗はexit 3、timeoutはexit 4。通常成功のJSON・medium・モデル無指定・キー除去を維持。
- bin/tests/codex-sub.test.cjs を追加。偽Codex・偽設定・偽キー値を使い、実API・認証情報を参照せず、成功・未ログイン・API認証・Fast・上限・timeout・失敗・空応答・バイナリ無しを確認。隣接dsh-subに起動検出用sentinelを置き、API fallbackが起動しないことも確認。テスト通過。
- 以前の「codex-subはAPI自動切替するため使えない」は上記実装で解消。過去節は履歴。
- Google APIはサブスクweekly limit到達時の同一モデル継続を事前許可（正本 §0.5）。low/medium、設定済みPrepay・auto-charge OFF経路に限定し、high格上げ申請を維持。未設定のAPI開通・チャージ・キー設定は今回行わない。
- 検証層は狭義Harness＋Context。Loop/Graphの追加は不要。取り消しは今回のbin・テスト・agents差分のみを逆適用。他スレッドの差分は保護する。
