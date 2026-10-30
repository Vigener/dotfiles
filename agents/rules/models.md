# モデル呼び出し（方針・クォータ）

正本: 本ファイル（dotfiles）。
タスク別の対応表: `docs/routing.md`。判定手順: スキル `model-route`。
参考: `research-brain/wiki/ai-engineering/subscription_and_api_playbook_2026-10.md`。
決定と教訓の履歴: `docs/history/2026-model-decisions.md`（経緯）と `docs/lessons.md`（事故）。どちらも**非規範**。

HPC 境界は `rules/hpc.md` を参照。

## 0. クォータの確認（数値を本文に書かない）

- 残量・リセット時刻は次で取得する:
  `~/dotfiles/bin/update-ai-usage --format markdown --no-notify --no-write-runcat`
- **このファイルに残量（%・$）を書かない。** 数値は日単位で陳腐化するため、判断には必ずコマンドの現在値を引用する。
- agy の枠は「Gemini」「Claude/GPT」「Argon」の3グループに分かれる。**Argon は別枠**。
- **残量のペースでモデルを動的に振り分けない**（手順は `model-route` から外した）。`update-ai-usage` は使い切り防止の確認に使ってよい。
- **計測期間（Linear RES-23、〜2026-11-07）**: W1 の `dsh-sub` 使用量は記録する。期間中は日次上限を設けない（旧「緊急時 $1〜2/日」は廃止）。

## 1. Gemini 4 Argon（agy 独立週枠）— アイデア出しのみ

- agy の Argon 独立週枠は**設計・仕様・実装前仕様化には使わない**（過去に実装ミスが続いたため）。
- **用途**: 発想・アイデア出し・問いの立て直し。週枠は繰り越されないので、発想セッションに計画的に使う。
- 消化後は Web 版 Argon へフォールバックしてよい（従来どおり）。

## 2. Cursor Pro（ローカルと Cloud Agent）

### 2.1 ローカル（T3 / `cursor-agent`）

- **Composer / Grok は原則使わない**（ローカルの W1 は `dsh-sub`。§2.5）。
- **例外（2つ）**:
  - **機密（Flag: Private）**: これまでどおり **Composer 2.5**（`fastMode: false` を明示した T3 / 非 Fast CLI）。
  - **Gemini 系・Claude 系以外のモデルが要る監査**: **Grok 4.7**（Fast 無効）。設計・日常司令塔には使わない。
- **Composer / Grok は申請不要。ただし Fast オフを明示した呼び出しに限る**（下記）。Fable は Other Models 専用・要許可。Opus 5.5 を Cursor で呼ぶのは禁止（`claude` を使う）。
- **Cursor モデル（Composer / Grok）は Fast を使わない**。T3 `delegate_task` は options 無しだと Fast で動く（2026-10-23 にダッシュボードで確認。UI は Fast オフと表示するが信用しない）。`target.options` に `fastMode: false` を**必ず**明示し、応答の `options` で確認する。CLI は `-fast` 無しの ID。明示せずに呼んだ場合は申請不要の範囲外（無許可の Fast 利用）として扱う。詳細は `docs/routing.md` §3。
- **Argon は `antigravity` 固定**。cursor のカタログに `gemini-4-argon` が出るが選ばない（Other Models は Fable 専用）。固定表は `docs/routing.md` §4。

### 2.2 Cursor Cloud Agent（作業エージェント）

**ローカル方針と切り離す。** Cloud Agent は従来どおり:

- **設計**: Grok 4.7（**必ず非 Fast**）
- **実装**: Composer 2.5（**必ず非 Fast**）

### 2.3 Gemini 3.8 Flash（agy）

- **実装（W1）から外す**。
- **担当**: ファイル探索、Web 検索（Flag: Search）、日本語推敲（yomiyasu、§2.8）、W2 の大文脈偵察。

## 2.5 Worker（実装役）とオーケストレーション

### 司令塔

- **オーケストレーターは Opus 5.5（Claude Team）**。旧記述の「Flash / Grok 4.6 司令塔」はローカル実態と合わないため廃止。

### 設計・仕様（大きなループ）

- **ループ最初に 1 回**: Opus が方向・仕様の骨子・完了条件（DoD）を決める（要許可 §3.6）。
- **細かい仕様**: Sonnet 5.5 **medium**（agy の Claude 週枠 → Team）。
- **Opus へ上げる**（Sonnet high ではなく Opus）: 同一タスク内で前提が崩れたとき、または**同じ指摘が 2 回**出たとき。
- 上げた**回数と理由を記録**する。多い場合は「最初から Sonnet high にする」切り替えを長い目で検討する（RES-23 の計測と合わせて見る）。

### W1 日常実装

- **第一候補**: `dsh-sub`（DeepSeek-V4.1-Flash-1017、`deepseek-flash` / effort `high`）。スキル `deepseek-harness`。
- DeepSeek V4.1 Flash Free（T3 `opencode`）は期間限定・SLA なし・OpenCode 内限定。W1 の代替経路にしない。
- 難所（W3）: Sonnet 5.5 medium → 上記の条件で Opus。

### 敵対的レビュー

- **Sonnet 5.5 medium + Opus 5.5**（Opus は high・要許可）。必要なら **Grok 4.7**（非 Fast）を加える。
- **大きなループの最後に Opus で 1 回**レビューする（要許可）。手順はスキル `adversarial-review`。

### DeepSeek API（`dsh-sub`）

- **W1 の主力**。`bin/dsh-sub`。既定 `deepseek-flash` / effort `high`。難所は `deepseek-v4-pro` / `effort max`（常用禁止）。無料枠と混同しない。Auto-reload は OFF。

## 2.8 yomiyasu（`nanaism/yomiyasu`）

- **大きなループの終わり**、人が読む文章に使う。担当モデルは **Gemini 3.8 Flash**（agy）。
- 依頼文で、【事実】【解釈】【未確認】などの **【】接頭辞**、見出し、箇条書き、番号、数値を**変えない**よう明示する。
- 推敲後は**元文との diff** を取って確認する。
- **本体と mini のどちらを使うか**は試行（Linear RES-24）で決める。それまではドキュメント上 **「試行中」** と書く。

## 2.9 残量の使い方（ペース方針の変更）

- **「リセットの 1 週間前に使い切る」Cursor ペースはやめる**。Cursor 月枠は、**各周期の終わりに数 % 残して** Cloud Agent 用に確保する。
- **Gemini 週次枠・Cursor 月次枠**がリセット前に多く残っていた場合、**本人が明示的に呼んだときだけ**追加で使う（自動的なバーンダウンで消費しない）。

## 3. Claude（Sonnet は agy、Opus は Team）

- **認証の確認**: `claude auth status` が `subscriptionType: "team"` なら、`claude` CLI と T3 の `claudeAgent` は **Team シート（サブスク）** で動く。従量 API ではない。
- **モデル別の置き場所**: **Sonnet 5.5 は agy（Google AI Pro の Claude 週枠）優先**、次点が Team。**Opus 5.5 は Team 優先**（オーケストレーター・ループ頭尾の設計/レビュー）、agy は週枠が余っているときだけ（事前許可制）。
- **Team は研究優先**: dotfiles / life-brain などの生活タスクで Team を使うのは、agy が枯れていて代替が無いときだけ。研究タスクは Team 優先。
- **認証の優先順位**: Team シート > Anthropic 従量 API（agy の Claude/GPT 週枠は別契約枠。全体の順序は `docs/routing.md`）。
- **API に切り替わる条件**: `ANTHROPIC_API_KEY` が設定されている、または `CLAUDE_CODE_SIMPLE=1` を使うと従量 API になる。使う前に `claude auth status` と環境変数を確認する。
- **Team 枠を使い切った場合**: Anthropic 公式 API を検討してよいが、API を使うならまず安価な DeepSeek 等を優先する。
- Claude 特有の自走が必要な局面では Sonnet 5.5 / Opus 5.5 を Team 枠で使う。`claudeAgent` は `binaryPath: claude` を叩くため、CLI と同じ認証を共有する。Opus を T3 から呼ぶなら `claudeAgent`、Sonnet なら `agy`（CLI）が既定。

## 3.5 effort の既定値

- 既定は **medium**。high は「成功条件が開いている」案件だけに使う。
- 閉じている（ルーブリック・DoD・テスト・差分がある）: medium。
- 開いている（何が良いか自体を決める）: high。
- 機械的（整形・分類・抽出）: low。
- モデルと effort は別軸。モデルを上げる前に effort を下げられないか考える。
- **役割の目安**: 計画・設計（何が良いか自体を決める）= Opus high（要許可）/ 細仕様 = Sonnet medium / 実装 = `dsh-sub`（W1）/ Cloud 実装 = Composer 2.5 / レビュー = Sonnet medium + ループ末 Opus / 探索・推敲 = Gemini Flash。
- **effort を変えるときは新しいスレッドで始める**。同一スレッドの途中で変えると、それまでの履歴を読み直すうえキャッシュも効きにくい（Antigravity の運用知見）。
- medium と high の品質差は小さいという報告が複数ある。差の有無は**モック実験ではなく普段の使用感**（返答の質・トークンの減り方）で判断する（2026-10-21 決定）。

| provider | 無指定のときの effort | 対処 |
|---|---|---|
| claudeAgent の Sonnet | **high** | `options` で medium を明示する |
| claudeAgent の Opus / Fable | medium | 明示不要。high にするときだけ書く |
| antigravity の Argon | モデル ID で決まる | `gemini-4-argon-medium` を既定にする。high は明示的な判断としてのみ |

## 3.6 許可の所在

- 呼び出し前の申請は **ファミリーと effort の格上げ** だけ。5h / 週枠の消費％を推定して申請しない。
- **要申請**: Fable 5.1 / Opus 5.5（全部）/ Sonnet 5.5 の high / Argon high（格上げ、3.7）/ Anthropic・OpenAI の従量 API。
- **申請不要**: Composer / Grok（`fastMode: false` を明示した場合のみ。§2）/ Gemini Flash / Argon medium / Sonnet medium / DeepSeek Free / 緊急窓の `dsh-sub`。
- **依頼者がモデル/effort を名指しした場合は、その1回分の許可とみなす**（提案も再確認も不要。例:「Argon high で設計して」）。

## 3.7 格上げの提案（名指しされたモデルは勝手に変えない）

- 名指しされたモデル/effort でも、成功条件が開いている（設計判断・前提の崩壊・論文の主張）と分かっていれば、**着手前に1行**で格上げ案を出す。
- **出力が格上げ後に再利用できない作業**（判断・主張の組み立て）は、承認が出るまで開始しない。再利用できる作業（調査・列挙・材料集め）は medium で進めてよい。
- 提案は1行・選択肢は最大2つ・推奨を1つ。返事が無いまま次の区切りを過ぎたら「保留」と報告し、他の再利用可能な作業へ移る（全体は止めない）。
- 格上げ先の順序: ①同一モデルの effort 上げ（要許可）②設計・前提崩れ・同指摘2回は **Opus**（要許可。Sonnet high より優先）③別ファミリー medium ④Fable（核ボタン）。**どの格上げ先でも、承認が出るまで切り替えない。**
- 名指しモデルの変更は承認があったときだけ（Strict Model Fidelity）。「任せる」と言われた場合はこの限りでない。

## 4. ゴール固定・敵対レビュー

- 長作業の開始時は、Goal・成功条件・制約・Next を短く書き出してから着手する（`now/TODO.md` か作業ノート。専用スキルは置かない）。
- 意地悪テスト生成・敵対的監査は「Maker-Breaker原則（実装と検証は異種モデル・コンテキスト完全隔離）」を遵守すること。W1 が DeepSeek のとき Breaker は Sonnet / Opus / Grok / Gemini Flash 等で組む。選定と詳細手順はスキル `adversarial-review` および `model-route` を参照。
