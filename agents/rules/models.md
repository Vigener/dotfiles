# モデル呼び出し（方針・クォータ）

正本: 本ファイル（dotfiles）。
タスク別の対応表: `docs/routing.md`。判定手順: スキル `model-route`。
参考: `research-brain/wiki/ai-engineering/subscription_and_api_playbook_2026-10.md`。
決定と教訓の履歴: `docs/history/2026-model-decisions.md`（経緯）と `docs/lessons.md`（事故）。どちらも**非規範**。

HPC 境界は `rules/hpc.md` を参照。

## 0. クォータの確認（数値を本文に書かない）

- 残量・リセット時刻・消費ペースは次で取得する:
  `~/dotfiles/bin/update-ai-usage --format markdown --no-notify --no-write-runcat`
- **このファイルに残量（%・$）を書かない。** 数値は日単位で陳腐化するため、判断には必ずコマンドの現在値を引用する。
- agy の枠は「Gemini」「Claude/GPT」「Argon」の3グループに分かれる。**Argon は別枠**。

## 1. Gemini 4 Argon 最優先 ＆ 週次バーンダウン規律（agy 独立週枠）

- agy に Google AI Pro 契約者向けの「Argon 独立週枠（完全別枠）」が正式常備。
- 週枠は繰り越されないため **「Use it or lose it（毎週使い切る）」**。温存心理を撤廃し、**日常4大門番（①実装前仕様化、②Diff敵対監査、③意地悪境界値テスト生成、④批判的文献読解）** に最優先で投入する。
- agy 側の週枠消化後は、Google AI Pro 付属の Web 版 Argon（無料）へフォールバックして使い倒す。

## 2. Cursor Pro（Composer 打鍵・Fable 専用）

- Grok 4.7 への日常の思考・設計丸投げを停止し、agy Argon へオフロード。Cursor 側は **Composer 2.5 (`agent --model composer-2.5`)** による打鍵・量産に特化させる。
- **Cursor は Fable 専用**。Fable 5.1 を選べる唯一のサブスクが Cursor なので、Other Models 枠は Fable に全振りする。ただし**呼び出しは事前許可制**（核ボタン・一撃で高額クレジットが蒸発した事故の教訓）。**Opus 5.5 を Cursor で呼ぶのは禁止**（`claude` を使う）。

## 2.5 Worker（実装役）の方針

- **既定**: DeepSeek V4.1 Flash Free（T3 の `opencode` 経由）。1M context / 出力 384K / $0。
- **Cursor 内の大量打鍵**: Composer 2.5。Cursor 枠は Composer 専用にし、Grok の設計利用で枯渇させない。
- **難所**: Sonnet 5.5（Team）。
- Free は **期間限定・SLA なし・OpenCode 内限定**。有料 1017（`deepseek/deepseek-flash`）をフォールバックに置く。
- Free の 1017 反映は **未確定**。動作で確認する。断定して書かない。
- **DeepSeek API（`dsh-sub`）**: 従量 API だが、`bin/dsh-sub`（スキル `deepseek-harness`）というワンショット契約済みのハーネスを持つ。既定 `deepseek-flash` / effort `high`、難所は `deepseek-v4-pro` / `effort max`（常用禁止）。**従量なので 3.6 のゲート対象**（無料枠と混同しない）。
- **DeepSeek の予算**: **月 $2・Auto-reload OFF**。残高が $0.5 を切ったら月1回だけ補充する。サブスクが主、API は「サブスクが枯れた日の圧力弁」なので、ここを増やす前に Argon / Team の枠を消化する。月 $2 は仮置き（実消費が $1 を超えた月が続いたら見直す）。


## 3. Claude（Sonnet は agy、Opus は Team）

- **認証の確認**: `claude auth status` が `subscriptionType: "team"` なら、`claude` CLI と T3 の `claudeAgent` は **Team シート（サブスク）** で動く。従量 API ではない。
- **モデル別の置き場所**: **Sonnet 5.5 は agy（Google AI Pro の Claude 週枠）優先**、次点が Team。**Opus 5.5 は Team 優先**、agy は週枠が余っているときだけ（事前許可制）。agy 側の Claude 週枠は減りが早く、途中で止まると作業が切れるため。
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
- **役割の目安**: 計画・設計（何が良いか自体を決める）= high / 実装 = Flash など安価なモデル / レビュー = low〜medium。
- **effort を変えるときは新しいスレッドで始める**。同一スレッドの途中で変えると、それまでの履歴を読み直すうえキャッシュも効きにくい（Antigravity の運用知見）。
- medium と high の品質差は小さいという報告が複数ある。差の有無は**モック実験ではなく普段の使用感**（返答の質・トークンの減り方）で判断する（2026-10-21 決定）。

| provider | 無指定のときの effort | 対処 |
|---|---|---|
| claudeAgent の Sonnet | **high** | `options` で medium を明示する |
| claudeAgent の Opus / Fable | medium | 明示不要。high にするときだけ書く |
| antigravity の Argon | モデル ID で決まる | `gemini-4-argon-medium` を既定にする。high は明示的な判断としてのみ |

## 3.6 サブスク枠のコストゲート

- 1タスクで 5h 枠の約 2% 以上、または週枠の約 5% 以上を消費しうる呼び出しは、**事前に1行で宣言して許可を取る**。サブスク枠も対象。
- 許可は呼び出し単位。「検証のため」は免除理由にならない。
- **依頼者がモデル/effort を名指しした場合は、その1回分の許可とみなす**（提案も再確認も不要。例:「Argon high で設計して」）。
- 同じモデル・同じ役割の短時間の再呼び出しは、理由を1行書く。

## 3.7 格上げの提案（名指しされたモデルは勝手に変えない）

- 名指しされたモデル/effort でも、成功条件が開いている（設計判断・前提の崩壊・論文の主張）と分かっていれば、**着手前に1行**で格上げ案を出す。
- **出力が格上げ後に再利用できない作業**（判断・主張の組み立て）は、承認が出るまで開始しない。再利用できる作業（調査・列挙・材料集め）は medium で進めてよい。
- 提案は1行・選択肢は最大2つ・推奨を1つ。返事が無いまま次の区切りを過ぎたら「保留」と報告し、他の再利用可能な作業へ移る（全体は止めない）。
- 格上げ先の順序: ①同一モデルの effort 上げ（要許可）②別ファミリー medium（Argon / Opus=要許可）③high（Opus high=要許可。**Argon high も選択肢**で、既定にはしないが「ここは high が要る」と判断したら理由1行で提案してよい）④Fable（核ボタン）。**どの格上げ先でも、承認が出るまで切り替えない。**
- 名指しモデルの変更は承認があったときだけ（Strict Model Fidelity）。「任せる」と言われた場合はこの限りでない。

## 4. ゴール固定・敵対レビュー

- 長作業の開始時は、Goal・成功条件・制約・Next を短く書き出してから着手する（`now/TODO.md` か作業ノート。専用スキルは置かない）。
- 意地悪テスト生成・敵対的監査は「Maker-Breaker原則（実装と検証は異種モデル・コンテキスト完全隔離）」を遵守すること。選定と詳細手順はスキル `adversarial-review`（`~/dotfiles/agents/skills/adversarial-review/SKILL.md`）および `model-route` を参照。
