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
# モデル呼び出しと HPC 境界（2026-07-31／2026-08-07 補訂）

1. **agy Opus 原則禁止**（Google AI Pro が即 5h limit）。発想の同等が必要なら Cursor Sonnet 5 の許可を求める。
2. **要許可**: Cursor Sonnet 5（発想・方針） / GPT-5.6 Terra（レビュー分析・計画の穴）。同役で並べない。無許可で可: pi(opencode-go 全)、agy(Gemini Flash/Pro, Sonnet 4.6, GPT-OSS)、Grok 4.5。**実装は `research-brain/wiki/ai-engineering/implementer.md` の model_id に自動委譲**（差し替えはその表だけ）。Composer は明示時のみ（Grok と Cursor 枠共有に注意）。
3. **Fable 5（Other）**: 長時間駆動・夜間放置連鎖はしない。**短時間の発想・問い切り・教員説明の穴・仮説1本の BRIEF は積極利用してよい**（司令塔 Grok が独断で「温存」して止めない）。テーマ全探索・Bレーン風呂敷再開・実装長文は渡さない。Sol は敵対・操作定義の穴向け（Fable と同日同問にしない）。
4. **HPC**: 生 `sbatch`/`qsub` および Miyabi/Pegasus/Sirius への `ssh`/`scp`/`rsync` は Cursor hook `hpc-shell-gate` が deny。必ず `ppx_harness` / `miyabi_harness --dry-run`。実ログインは人間。
5. **ゴール固定**: 長作業の開始時はスキル `goal`。敵対レビューはスキル `adversarial-review`（T3 は許可時 Terra。stop hook に載せない）。
6. 前提の賞味期限: `research-brain/wiki/ai-engineering/ops_assumptions.md`。
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
