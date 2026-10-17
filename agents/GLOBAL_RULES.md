# Global AI Agent Rules

このファイルは、どのディレクトリにいる場合でも利用できる汎用的なAIエージェントのルールとスキルの案内です。

## 0. 用語・省略名

マシン・リポの略称（**MBA / TB / mini / rb / sandbox / KE** 等）は  
`~/dotfiles/agents/glossary.md` を正本とする。会話中の略もこれに合わせること。

## 1. グローバルスキル (Skills) の活用
特定のタスク（Miyabi等のHPCジョブ投入、Gitのセマンティックコミット等）を実行するための専門的な「スキル（手順書・プロンプト）」が以下のディレクトリに格納されています。

- `~/dotfiles/agents/skills/`

関連するタスクを行う際は、事前に該当ディレクトリ内にある `SKILL.md` をファイル読み取り機能で確認してから実行してください。

<RULE[artifact_auto_sync]>
# Thinkpadでの作業方針と自動アーティファクト同期ルール
Thinkpad環境（agy cli等）で作業を行なう際のエージェントは、以下の規定に必ず従うこと。

1. **作業ログとREADMEの分離**:
   - 作業中（計画立案やエラー対応、試行錯誤の過程など）のログファイル（例: `migration-log.md`）は、必ずプロジェクト内の `logs/` または `docs/logs/` ディレクトリを作成してそこに隔離し、保存・追記しながら進めること。プロジェクトのルートディレクトリはクリーンに保つこと。
   - `README.md` には、そうした試行錯誤の過程を記載せず、「最終結果」と「根幹部分のみ」を抽出した一般的なREADMEとしての役割を果たすよう綺麗にまとめること。
2. **成果物と図表の配置**:
   - 成果物（レポートPDFや、概観用・提出物系のMarkdownファイル）は必ずプロジェクトルートに作成すること。
   - それらの中で参照する図表類（画像ファイル等）は、プロジェクトルートの `images/` ディレクトリに保存すること。
</RULE[artifact_auto_sync]>

<RULE[artifact_handoff_html]>
# 成果物ハンドオフ（エージェント間 vs 人間レビュー）

2026-07-31 取り決め。詳細手順はスキル `open-artifact` / `update-agent-config`。

1. **エージェント間・中間成果**: Markdown / 構造化テキスト（差分・grep・機械可読を優先）。`inbox/`・`logs/`・作業ノート。
2. **人間レビュー・保存版概念解説**: HTML（`wiki/`）。フォーマットガイド: `research-brain/.agents/references/wiki_formatting_guide.md`。
3. **セッション終了時（best-effort）**: 人間向け HTML を更新したら `open-artifact` スキルに従い、MBA でブラウザを開く（`ssh mac 'open URL'`）。オフライン時の失敗は無視して URL をチャットに出す。
4. **配信**: 母艦（**mini**）の `http-brain`（:8766）等。素の `python -m http.server` 禁止（`thinkpad-resident`）。略称は `glossary.md`。
5. **挙動設定の変更**: 必ず `update-agent-config` で層（Context / Harness / Loop / Graph A/B）を判定してから最小変更する。
</RULE[artifact_handoff_html]>

<RULE[model_and_hpc_gates]>
# モデル呼び出しと HPC 境界（2026-10-16 確定改定）

正本: `research-brain/wiki/ai-engineering/user_model_routing_mental_model.md`（各環境スナップショット: `~/dotfiles/agents/docs/user_model_routing_mental_model.md`）および `subscription_and_api_playbook_2026-10.md`。

1. **Gemini 4 Argon 最優先 ＆ 週次バーンダウン規律（agy 独立週枠）**:
   - agy に Google AI Pro 契約者向けの「Argon 独立週枠（100%別枠）」が正式常備。
   - 週枠は繰り越されないため **「Use it or lose it（毎週100%使い切る）」**。温存心理を撤廃し、**日常4大門番（①実装前仕様化、②Diff敵対監査、③意地悪境界値テスト生成、④批判的文献読解）** に最優先で投入する。
   - agy 側の週枠消化後は、Google AI Pro 付属の Web 版 Argon（無料）へフォールバックして使い倒す。
2. **Cursor Pro（残り6.4%）クォータ防護と Composer 打鍵特化**:
   - Grok 4.7 への日常の思考・設計丸投げを停止し、agy Argon へオフロード。Cursor 側は **Composer 2.5 (`agent --model composer-2.5`)** による打鍵・量産に特化させる。
   - **Cursor からの Fable 5.1 / Opus 5.5 の呼び出しは厳禁（核ボタン・1発25%/$5蒸発事故の教訓）**。
3. **Anthropic 公式 API（Claude Code CLI）スポット配備**:
   - Claude Sonnet 5.5（ターミナル `claude`、Prompt Caching 5分自動延長）は、無料の Argon 枠消化後や、Claude 特有の自走が必要な局面での「Tier 3 有料スポット最終兵器（$5デポジット・Auto-reload OFF）」として温存。
4. **HPC**:
   - 生 `sbatch`/`qsub` および Miyabi/Pegasus/Sirius への `ssh`/`scp`/`rsync` は Cursor hook `hpc-shell-gate` が deny。必ず `ppx_harness` / `miyabi_harness --dry-run`。実ログインは人間。
   - ジョブスクリプト作成、スケーリング実験計画、クラスタ投入準備を行う際は、必ず事前にスキル `hpc-job-guardrails`（`~/dotfiles/agents/skills/hpc-job-guardrails/SKILL.md`）を読み込んでその規律（ノード分離・2ノード関門・ログインノード完結・Fail-Fast）を遵守すること。
5. **ゴール固定・敵対レビュー**:
   - 長作業の開始時はスキル `goal`。敵対的監査は agy Argon を優先し、必要に応じてスキル `adversarial-review` を使用。
</RULE[model_and_hpc_gates]>

<RULE[adversarial_scope]>
# 敵対レビューのスコープ（2026-08-07）

正本: 本ファイル `RULE[model_and_hpc_gates]` §3（Fable↔Sol 同日同問禁止）およびスキル `~/dotfiles/agents/skills/adversarial-review/SKILL.md`。

1. **正本に無い使用上限を発明しない**（例: Fable 1日1回、別 BRIEF の別日必須、案Aと案Bの同日禁止）。
2. **「同日同問」は Fable↔Sol（または同役二重）に限定**。Fable の別 BRIEF・別セッションでの同日 A→B は禁止理由にしない。
3. 疑わしい制限指摘は severity を major にせず **nit** とし、**正本の該当行を引用必須**。引用できなければ指摘しない。
</RULE[adversarial_scope]>

<RULE[delegate_channel]>
# 委譲チャネルの目安（2026-08-07）

**優先の目安**であり、Cursor Task による実装を全面禁止しない。

1. **実装・多段（編集→pytest→修正）**: 原則 `herdr pane split` + `agent start/prompt`（別ペイン・監視しやすい）。Task でも可だが長時間実装は herdr 優先。
2. **敵対レビュー・視点提案・採点（read-only・短時間・戻り値で足りる）**: Cursor Task / `agy` / `pi` で可。herdr 必須にしない。
3. **コンテキスト分離**: 別 BRIEF は `/clear` または別ペイン。モデル切替は `/model`。
4. **モデル名を先頭に（可視性）**: Cursor Task の `description` は `{通称} {短い作業}`（例: `Fable open-artifact audit`）。UI の「Running N agents…」に出る。通称は人が呼ぶ名前だけ（Grok / Fable / Composer / Sol / Terra / Luna / Gemini Pro / Gemini Flash）。版数・slug は書かない。inherit なら親と同じ。agy / pi / herdr は呼ぶ直前にチャットへ `{通称} を呼び出します` を1行。
</RULE[delegate_channel]>

<RULE[paper_claim_level_and_language]>
# 論文・成果説明の義務（2026-08-07）

論文／投稿／教員説明／「論文に載せる言い方」に触れる応答・成果物では、毎回ユーザーに聞かなくても次を併記する。

1. **成果レベル（必須）**: いまの束がどの天井か、短いスケールで明示する。例:
   - 作業メモ／内部ログのみ
   - 卒業論文の一章ドラフト
   - 学内発表・ゼミ報告
   - 国内 WS／研究会 投稿候補
   - 国際 WS 投稿候補
   - 国際会議本会議／ジャーナル（この段階に無いなら「未達」と書く）
   「出せるかもしれない」曖昧語で止めず、**到達済み／あと何が足りないか**を1–3行で書く。
2. **教員・非専門家向け文**: 自分勝手な和訳ラベル（例: レジーム地図、観測アブレーション、事後帯）を説明なしに並べない。
   - 使うなら **普通の日本語で状況を説明する**か、**英単語をそのまま**（Ready / flush / background load 等）。
   - 記号（O2a, OBS_R1 等）は初出で一言定義。専門外でも追える文にする。
3. **過信禁止**: 司令塔単独の「これで十分／新規テーマ不要」断定を避け、Fable 等の短時間発想を選択肢として残す。捏造・未実施実験の勝利宣言はしない。
</RULE[paper_claim_level_and_language]>

<RULE[link_portability_and_cli_format]>
# リンク記法・ファイル内リンクのポータビリティルール（2026-09-26）

Ghostty CLI / Herdr 環境での閲覧性、および SMB 経由（MBA）での Obsidian 閲覧ポータビリティを保証するための全エージェント共通規定。

1. **チャット回答文でのリンク記法（Ghostty CLI / Herdr 最適化）**:
   - ホスト絶対パスの `file:///...` リンクは一切出力しないこと（Ghostty CLI ではクリック不可で視覚的ノイズになるため）。
   - ファイルに言及する際は、シンプルな相対パス（例: `notes/lecture-outline.md`、`wiki/hpc/foo.md`）またはファイル名のみで表記すること。
   - ブラウザで開くべき成果物（HTML 等）のみ、コピーして即開ける `http://mikotomac-mini:8766/...`（または Tailscale URL）の形式で提示すること。
2. **ファイル内リンクの絶対パス禁止（ポータビリティ保証）**:
   - リポジトリ内のファイル（`.md` や `.html` 等）にリンクを記述する際は、**絶対にホスト固有の絶対ファイルパス（`file:///Users/...` 等）を書き込まないこと**。
   - 必ず **相対パス（例: `./path/to/file.md`、`../notes/file.md`）** または **Obsidian の WikiLink 記法（`[[filename]]`）** を使用すること（MBA 側から SMB 共有経由で開いた際にファイルが存在せずリンク破損・外部警告が出るのを防ぐため）。
</RULE[link_portability_and_cli_format]>


<RULE[subagent_isolation_and_cli_fallback]>
# サブエージェント委譲の隔離原則と使い分け規律（2026-10-16 確定改定）

1. **委譲の目的（コンテキスト汚染防止と役割分離の死守）**:
   - ユーザーがサブエージェント委譲を指示・意図する本質は、**「親エージェントのコンテキスト汚染（大量の打鍵・ログ・ツール実行による Context Rot）を防止すること」**、および **「司令塔（Commander）と作業役（Worker）の関心事を厳密に分離すること」** にある。
2. **インライン引き受けの絶対禁止（親が自前実行してはならない）**:
   - サブエージェント起動や委譲がエラー（`PlatformClient is nil` 等）で失敗した際、**親エージェントが「失敗したから親が直接インラインでツールを実行する」と親のチャット内で連打して引き受けることは厳禁**。
   - 親が引き受けると、ユーザーがせっかく意図して設計したコンテキスト分離・役割分担がすべて破綻する。
3. **T3 Code 環境における委譲ツールの2大系統と使い分け**:
   - **系統A: T3 MCP オーケストレータ (`delegate_task`) 【親と異なるモデル・クロスプロバイダ】**:
     - **用途**: 親と異なるモデル（例: **Gemini 4 Argon**）への委譲、クロスプロバイダ委譲、T3 ネイティブ子タスク起票。親（Flash 等）から上位思考モデル（Argon 等）へのエスカレーション設計に必須。
     - **呼び出し方**: `call_mcp_tool` で `ServerName: "t3-code"`, `ToolName: "delegate_task"`, `Arguments: { target: { providerInstanceId: "antigravity", model: "gemini-4-argon-high" }, mode: "wait" (または "async"), role: "design", task: "..." }`
     - **特徴**: T3 側のライブカタログ（`orchestrator_capabilities`）を参照して独立した子スレッドを起票するため、Argon を思考高（`gemini-4-argon-high`）で正常実行可能（初回設計で実証済）。
   - **系統B: Antigravity ネイティブサブエージェント (`invoke_subagent`) 【親と同種モデル・高速並行】**:
     - **用途**: 親と同じモデル（Flash 等）での軽量・超高速並行処理、Context Rot 防止の作業員委譲。
     - **呼び出し方**: `invoke_subagent` で **必ず `Model: "inherit"` を指定** する。
     - **注意点**: `Model: "flash"` や `"pro"` 等の明示文字列を渡すとローカル ACP ハーネスの `PlatformClient is nil` でクラッシュする。`"inherit"` を渡せば名前解決サービスをスキップして親構成をそのまま安全に複製できる（親と異なるモデルへの変更は不可）。
4. **外部 CLI フォールバック (`agy` / `cursor-agent`)**:
   - プラットフォーム内蔵委譲が環境制約等で利用不能な場合、またはターミナルから外部プロセスとして直叩きする場合、直ちに `run_command`（Bash）経由で外部 CLI エージェントを起動し、**完全に別プロセスでタスクを実行・隔離** させる。
   - **フォールバック先選定（モデルルーティング準拠）**:
     - **打鍵・スキャフォールディング・探索（無料・Google AI Pro 枠）**:
       `agy --model gemini-3.8-flash-high --dangerously-skip-permissions -p "プロンプト"`
     - **コーディング・実装・テスト修正（Cursor Pro 定額枠）**:
       `cursor-agent --model composer-2.5 "プロンプト"` または `--model grok`
     - **超高度設計・数理仕様化・敵対的監査（Argon 週枠バーンダウン）**:
       `agy --model gemini-4-argon-high --dangerously-skip-permissions -p "プロンプト"`
   - **【モデル同一性の厳格遵守（Strict Model Fidelity）】**:
     - 最初にT3サブエージェントとして指定・意図されたモデル（例: `flash`）と**全く同一のモデル**を CLI 引数に指定すること。
     - 勝手に別のモデル（Argon や Composer や Opus 等）へ変更・昇格/降格することは**論外・厳禁**。
       - `flash` 指定時 ➔ 必ず `agy --model gemini-3.8-flash-high`
       - `composer` 指定時 ➔ 必ず `cursor-agent --model composer-2.5`
       - `argon` 指定時 ➔ 必ず `agy --model gemini-4-argon-high`
     - 指定モデルの枠（クォータ・コスト）を 100% 守る。
5. **親エージェントの振る舞い**:
   - 子エージェント（`delegate_task` / `invoke_subagent` / CLI）の完了ステータス、生成成果物のコミットハッシュ、要約のみを親コンテキストに報告する。中間作業ログを親コンテキストに持ち込まない。
</RULE[subagent_isolation_and_cli_fallback]>
