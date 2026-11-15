# モデル呼び出し（方針・クォータ）

正本: 本ファイル（dotfiles）。
タスク別の対応表: `docs/routing.md`。判定手順: スキル `model-route`。
参考: `research-brain/wiki/ai-engineering/subscription_and_api_playbook_2026-10.md`。
決定と教訓の履歴: `docs/history/2026-model-decisions.md`（経緯）と `docs/lessons.md`（事故）。どちらも**非規範**。

HPC 境界は `rules/hpc.md` を参照。

## 0. クォータの確認（数値を本文に書かない）

- Cursor / Claude Team / Codex / DeepSeek の残量・リセット時刻は次で取得する:
  `~/dotfiles/bin/update-ai-usage --format markdown --no-notify --no-write-runcat`
- **このファイルに残量（%・$）を書かない。** 数値は日単位で陳腐化するため、
  判断には必ずコマンドの現在値を引用する。
- agy の枠は「Gemini」「Claude/GPT」「Argon」の3グループに分かれる。
  **Argon は別枠**。ただし **Google 規約順守のため `update-ai-usage` から
  `agy -p /usage` の自動取得を除外済み**（§0.5）。`agy` 残量は人間が T3 /
  Antigravity UI で確認する。
- **残量のペースでモデルを動的に振り分けない**（手順は `model-route` から
  外した）。`update-ai-usage` は使い切り防止の確認に使ってよい。
- **DeepSeek API の日次上限（旧「緊急時 $1〜2/日」）は廃止**した。
- **計測期間（Linear RES-23、〜2026-11-07）**: 毎晩1行で **Codex 残**
  （ダッシュボードか `/status`）、**Codex に渡したタスク数**と
  **Opus の差戻回数・理由**、**Claude Team 残**、**Cursor 残**、
  **Gemini 残**、**DeepSeek USD** を記録する（詳細は `logs/res23/README.md`）。
  期間中は日次上限を設けない。`dsh-sub` は消さない（契約前・枠切れの控え）。
  期間後は RES-23 の結果を見て本人が方針を決める。
- **枠が足りないとき**: RES-23 の計測を見て、週後半に
  **Anthropic API 従量課金**または **Claude Pro 契約**を足すか本人が決める
  （§2.5 敵対レビュー・§3 と同趣旨）。

## 0.4 判断・発想・監査のペア運用（2026-11-16 暫定）

### 研究担当と worker の分担（2026-11-16、本人承認）

- **追加承認：Hydrogen / Grok を積極利用してよい（本3研究タスク）。**
  Hydrogen は検索・一次資料確認・広いリポジトリ探索・抽出・判断材料整理、
  Grok は独立した探索・案出し・比較検討・範囲を切った実装に利用できる。
  本3タスクでは、後続の Grok を Visual QA / Opus 不在時の代行だけに限る
  用途制限より本項を優先する。担当の方針・評価契約・根拠確認・統合責任は維持。
  Grok + Hydrogen の組合せも活用できるが、軽作業まで常にペアにしない。
  モデル利用許可は全員並走の義務ではなく、必要な仕事を適切に切り出す許可。
  課金経路・Fast off・個別のモデル/役割指定・HPC操作境界は維持する。

- QEC・ftqc・b4 の担当は方針、評価契約、統合、次の人間操作までの進行を担う。
  担当モデルが全実装・全探索を自分で行うことを既定にしない。
- 切り出せる実装は Terra / Sonnet、範囲の明確な検索・リポジトリ探索・抽出は
  Luna / Haiku / Hydrogen などへ委譲してよい。ただし **§0.5 の規約境界により、
  他エージェントから `delegate_task` で `antigravity` や CLI `agy -p` を呼ぶことは
  禁止**。エージェントが Hydrogen / Argon を使う場合は API 経路
  （`bin/hydrogen-sub` / `bin/argon-sub`・テキスト専用）を用い、リポジトリ探索や
  ツール操作が必要な検索 worker は `codex`（Luna / Terra）・`claudeAgent`
  （Haiku / Sonnet）・許可タスク内の Grok（非 Fast）へ割り当てる
  （人間が直接操作する `antigravity` ルートスレッドでの Hydrogen / Argon 利用は可）。
  これは本3タスクに限る用途の許可で、全タスクの既定モデルや課金・Private制約を
  変更しない。
- ライブカタログで提供モデルと設定を確認し、未提供モデルを推測で呼ばない。
  現担当の指定・待機理由・既存の分担を守り、権限を理由に不要な仕事を増やさない。
- 短い修正や強く結合した処理は担当が行う。子には対象、完了条件、境界を短く渡し、
  実装の裁量を残す。巨大な全履歴の再読込、多数の常設子、連鎖委譲は避ける。
- 同じサブスク枠の子利用や引継ぎ費用も消費に含まれる。安価なモデル名だけで
  節約できると断定せず、再作業・担当の読戻しを含む総量を見る。
- 独立監査のペア方針は以下を維持。検索 worker ごとにペア監査を常設しない。

- Carbon のサブスク解放は時期未定で、解放されない可能性も考慮する。
  Carbon の登場を待って研究を停止したり、未提供のモデルを前提にしない。
- **Argon を判断材料・発想・監査に使う場合は、原則 Hydrogen と組み合わせる。**
  Argon medium が論点・異論・監査を担当し、Hydrogen high が一次資料・
  数値・コード上の根拠を独立に確認する。Hydrogen 単独の調査・抽出まで
  常に二重化する意味ではない。Hydrogen を独立 Breaker の代わりにはしない。
- **Grok + Hydrogen も試行候補**。Grok を判断役として使う許可済みタスクでは
  Hydrogen の独立確認を組み合わせることを検討する。Grok の用途禁止・
  Fast off・課金経路・個別のモデル指定を解除しない。
- ペアの一致を正しさ・新規性の保証としない。根拠と不一致を担当者が統合し、
  人間の承認事項や設計責任を多数決で置き換えない。追加委譲禁止・Private 等の
  タスク制約でペアを作れない場合、未確認点を明示して報告する。
- 理由は本人の使用感とベンチマーク比較への懸念。全領域でのモデル優劣を
  確定した方針ではなく、実作業で有用性とトークン消費を見て見直す。
  **Hydrogen の使用増で消費速度が速すぎる場合、Argon + Grok などへ変更する
  可能性がある。変更は本人と相談して決め、残量だけで自動切替しない。**
- 本節は、後続の Argon 単独を既定とする発想・暫定監査の記述に優先する。
  その他のモデル・effort・利用経路・役割の制約は維持する。

## 0.5 Google サブスクと API（2026-11-16 規約順守改定）

- **操作主体による厳格分離（Google 規約順守）**:
  - **Google AI Pro サブスク（`antigravity` / `agy`、`oauth-personal`）**:
    **人間が T3 Code UI 等で直接起動・入力するルートスレッド専用**
    （そのルートスレッド内での同モデル `invoke_subagent` `Model: "inherit"` のみ可）。
    他エージェント（`claudeAgent` / `codex` / `cursor` / `opencode` 等）からの
    `delegate_task(..., providerInstanceId: "antigravity")`、`antigravity` 自身からの
    `delegate_task(..., "antigravity")`、およびエージェントや自動実行
    （`launchd` / `cron` / `update-ai-usage`）からの `agy -p` / `agy acp` 起動は
    **全面禁止**。
  - **他エージェント / 自動処理からの Gemini 呼び出し**: 必ず下の
    **Google Developer API 経路**（`bin/gemini-sub` / `bin/hydrogen-sub` /
    `bin/argon-sub` / `bin/carbon-sub` / `bin/flash-sub`）のみを使う。
    `~/.config/gemini-sub/.env` は **Prepay / オートチャージ OFF が確認済み**
    （2026-11-13）であり、エージェント適合タスク（テキスト要約・推敲・テキスト監査等）
    では都度確認なしで呼び出してよい。
- API の既定はモデルごとの規定どおり（`hydrogen-sub` / Hydrogen は既定 `high`・
  軽作業のみ `low` 可、`argon-sub` / `carbon-sub` / `flash-sub` は既定
  `medium`）。**無意味な格上げ（Argon / Carbon の `high`、Hydrogen の
  `xhigh`）は禁止**する。難所・開かれた問題等でこれらが必要なときは、理由を
  1 行記録すれば **事後報告可**とする（Google API および Hydrogen の
  `xhigh` は §3.6–§3.7 の事前承認待ちを要しない。Codex / Opus / Fable の
  事前承認規則や、用途禁止・Private 境界は解除しない）。
- API の利用許可と課金設定の変更は別。未設定経路の開通・チャージ・オートチャージ
  有効化は禁止。Prepay 枯渇（`429` / `RESOURCE_EXHAUSTED`）時は即時停止
  （`exit 3`）し、課金設定を変えず **`agy` サブスクへ自動逃避もしない**
  （人間へ停止報告、または非 Google プロバイダへの切替可否を確認）。
  支出・トークン使用量・理由を記録し、残高や単価の金額は正本文に固定しない。
- **人間直操作スレッドでの Google AI Pro 枠切れ後のフォールバック順**:
  - **Argon 独立週枠を消化したとき**: 低ハルシネーション（`AA-Omniscience`）や
    図表読解が必須でない作業は、別枠の **`agy` `gemini-4-hydrogen`**（人間直操作）
    または **Web 版 Argon** を優先する。Argon 自体が必要な場合は **`bin/argon-sub`**
    を使う。
  - **Gemini 枠（Hydrogen / 3.8 Flash）を消化したとき**: **`bin/hydrogen-sub`**
    を使う。
  - **エージェントからの有料 API 呼び出し時のモデル優先**: API では `argon-sub` の
    利用を最小化し、速度・単価・コーディング効率で優れる **`hydrogen-sub`**、または
    最深推論の **`carbon-sub`** を主軸にする（`argon-sub` は低ハルシネーション検証、
    暫定監査、Carbon タイムアウト退避に絞る）。
- **実行チャネルと認証隔離（サブスク保護）**: T3 Code 設定やシェル全体
  （`.zshrc` 等）に `GEMINI_API_KEY` を登録しない（サブスク枠の誤消費・API
  引きずり込み防止）。API 実行は独立 CLI `bin/gemini-sub`（既定
  `gemini-4-hydrogen` / `high`、SSE ストリーミング `:streamGenerateContent?alt=sse`・
  `xhigh` 対応）および既定モデル固定ラッパー `bin/hydrogen-sub`
  （`gemini-4-hydrogen` / `high`）・`bin/carbon-sub`（`gemini-4-carbon` /
  `medium`）・`bin/argon-sub`（`gemini-4-argon` / `medium`）・`bin/flash-sub`
  （`gemini-3.8-flash` / `medium`、レガシー控え）を使い、キーは専用ファイル
  `~/.config/gemini-sub/.env`（パーミッション `600`）または一時環境変数からのみ
  読み込む。
- **ラッパーの動作特性と Carbon 運用ガードレール（2026-11-10 実測教訓）**:
  `gemini-sub` 系は単発テキスト API 要求であり、ファイル探索・編集やツールループは
  持たない（`--repo` は実在検証のみ）。`gemini-4-carbon` は長い思考を伴うため、
  `--timeout 900`（既定）を維持し、巨大な生プロンプト（数十 KB の無選別ログ等）を
  避けて要点・対象差分に絞る。`gemini-sub` は SSE ストリーミングで接続するため
  HTTP ヘッダ待機（300s）では落ちないが、壁時計タイムアウト（`exit 4`）時は
  プロンプトを圧縮して再試行するか、制約に反しない範囲で `argon-sub` /
  `hydrogen-sub` へ切り替える（モデル固定指定時は停止して報告）。

## 1. Gemini 4 Argon（人間直操作 `agy` 独立週枠 / API `argon-sub`）— 発想（監査の暫定例外は §2.5）

- Argon は**設計・仕様・実装前仕様化には使わない**
  （過去に実装ミスが続いたため）。
- **用途**: 発想・アイデア出し・問いの立て直し。`agy` の独立週枠は繰り越されないため
  **人間が T3 で直接 Argon スレッドを立てる**発想セッションに計画的に使う。
  **エージェントが発想や暫定監査で Argon を呼ぶ場合は必ず `bin/argon-sub`
  （API）** を使う（§0.5）。
- 監査への暫定利用は §2.5「暫定監査」に従う。設計・仕様・実装前仕様化の
  禁止は維持する。
- 公式ベンチマーク上の優位点（§1.2 比較）として、Hydrogen より
  **低ハルシネーション率（AA-Omniscience）**・図表読解（Chartography）・
  Terminal-Bench-Science 0.1 に強みを持つ。
- 人間直操作枠の消化後フォールバックは §0.5（`agy` Hydrogen / Web Argon →
  必要時 `argon-sub`）に従う。

## 1.1 Gemini 4 Carbon（Argon の置換ではない。2026-11-11、2026-11-13 更新）

- 公開は 2026-11-10。モデルカードは Carbon を Argon ベースと書く。公式の使い分けは、
  Argon をソフトウェア工学と知識労働の多数向け、Carbon を知能の限界を試す作業
  （複雑な多段のコーディングとデバッグ、開かれた科学的探求）向けとする。
  Carbon は Argon より多くのトークンを使って探索・推論・検証する。料金表は
  Argon を、Carbon より応答が速くターンあたりのトークンが少ない側と書く。
- Developer API の有料枠に `gemini-4-carbon` と `gemini-4-argon` が並ぶ
  （Free は両方なし）。API 経路では `bin/carbon-sub`（`gemini-4-carbon` /
  `medium`）を用意し、§0.5 の事前許可の範囲（限界を試す難所・科学的探求）で
  呼べる形にした。トークン消費が多いため、通常作業を安易に `carbon-sub` へ
  逃がさない。
- 導入期間は 2026-11-30 まで、標準単価は 2026-12-01 から。Argon と Carbon の
  単価スケジュールは同じで、金額は写さない（§0.5）。期間後に料金表とこの節が
  食い違っても、Carbon を安い代替として自動優先しない。掲載単価が同じでも
  Carbon はトークンが多いため、割引終了後に Argon の安い代替へ切り替えない。
- 人間の前提（2026-11-11）: Carbon は Google AI Pro の Antigravity にも来る可能性が
  あるが、`cursor` に出ても選ばない。**§0.5 の規約順守により、エージェントから
  `delegate_task` で `antigravity` の Carbon を呼ぶことは禁止**。エージェントは
  API 経路の `bin/carbon-sub` のみを使い、`antigravity` 掲載後のサブスク利用は
  人間が T3 UI で直接スレッドを立てる場合に限る。
- 掲載後も、発想と暫定監査は Argon（§1、§2.5）。設計・仕様・W1 は Opus / Codex
  のまま。Carbon は複雑な多段デバッグと開かれた科学的探求に限る。
  Argon の weekly limit を Carbon（`carbon-sub`）で埋めない（§0.5）。

出典: [Gemini 4 Carbon is now available](https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-4-carbon-now-available/)、
[Gemini Developer API pricing](https://aistudio.google.com/docs/pricing)、
[Google AI plans](https://one.google.com/about/google-ai-plans/)。

## 1.2 Gemini 4 Hydrogen（3.8 Flash からの移行先。2026-11-13）

- 公開は 2026-11-12。公式は `gemini-3.8-flash` および旧世代からの推奨アップグレード
  先かつ Antigravity Agent の既定モデルと位置づける。Gemini 4 共通の統合 1M
  コンテキスト、同期 64K 出力（長文デコード最大 1M）、4 段階の `thinking_level`
  （`low` / `medium` / `high` / `xhigh`。`minimal` は非対応でエラー）を持つ。
- **既定 `thinking_level`**: Argon / Carbon / 3.8 Flash は既定 `medium`、
  **Hydrogen は `agy`・API（`hydrogen-sub`）とも既定 `high` のまま運用**する
  （呼び出し時の `medium` 明示は不要。単純な抽出・整形のみ任意で `low` 可）。
  **`xhigh`** はチャネルを問わず無意味な引き上げを禁止し、難所等で必要なときだけ
  **理由を 1 行記録して事後報告可**（§0.5・§3.6）。
- **Argon・Carbon との公式比較（全領域で Hydrogen > Argon ではない）**:
  - **Hydrogen が上回る領域**: 応答速度（3.8 Flash 比約 2.5 倍、Argon より高速）、
    API 単価の低さ（金額は写さず料金表を参照）、3.8 Flash 比 5 倍以上の捏造削減、
    SWE-sweep / FrontierCode 2.0 / CursorBench 4.0 / AA Intelligence Index /
    HLE-Diamond。Carbon や Argon（計画・難所・最終検証）と Hydrogen（並列ワーカー・
    実行・テスト検証）を組み合わせるオーケストレーションが公式推奨。
  - **Argon が上回る領域**: **AA-Omniscience 低ハルシネーション率**、Chartography、
    Terminal-Bench-Science 0.1。加えて `agy` Pro では Argon は非繰越の独立週枠、
    Hydrogen は `Gemini Models` 枠共有。
- **運用方針**: 人間直操作の `agy` スレッドでは旧 Gemini 3.8 Flash の役割（§2.3・§2.8）を
  **すべて Gemini 4 Hydrogen へ移行**し、Argon の独立週枠は発想セッション（§1）に
  温存する。**エージェントからの委譲**は §0.5 に従い、テキスト処理は
  `hydrogen-sub` / `carbon-sub`（暫定監査等は `argon-sub`）、ツール・ファイル探索・
  PNG 目視は `codex` / `claudeAgent` / `cursor`（非 Fast）へ切り分ける。

出典: [Gemini 4 Hydrogen docs](https://aistudio.google.com/docs/models/gemini-4-hydrogen)、
[What's new in Gemini 4 Hydrogen](https://aistudio.google.com/docs/whats-new-gemini-4-hydrogen)、
[Gemini 4 Hydrogen model card](https://deepmind.google/models/model-cards/gemini-4-hydrogen/)、
[Gemini Developer API pricing](https://aistudio.google.com/docs/pricing)。

## 2. Cursor Pro（ローカルと Cloud Agent）

### 2.1 ローカル（T3 / `cursor-agent`）

- 研究以外の司令塔は §2.5 に従う。以下は研究タスクの既定。
- **Composer / Grok は原則使わない**（ローカルの W1 は `codex-sub`。§2.5）。
- **例外（3つ）** — いずれも **Grok / Composer は Fast オフを明示**
  （本ファイル §2.1 の Fast 手順、`docs/routing.md` §8）:
  - **機密（Flag: Private）**: **Composer 2.5**
    （`fastMode: false` を明示した T3 / 非 Fast CLI）。
  - **Visual QA（エージェント実行の第一候補／人間 Hydrogen の代替）**:
    他エージェントが PNG 目視を委譲する場合は **Grok 4.7**（`fastMode: false`、
    `docs/routing.md` §3 Visual QA）。人間が T3 UI で `antigravity` Hydrogen
    スレッドを直接開いて確認する場合は Hydrogen を優先可。
  - **Opus 5.5 が使えないときのオーケストレーター代行**: **Grok 4.7**
    （Team / `claude` が使えない局面のみ。代行できるのが Grok だけだが
    枠のリセットまでが長いため、平常時は Opus・用途はこの2例外に限定して温存）。
- **Composer / Grok は申請不要。ただし Fast オフを明示した呼び出しに限る**
  （下記）。Fable は Other Models 専用・要許可。Opus 5.5 を Cursor で
  呼ぶのは禁止（`claude` を使う）。
- **Cursor モデル（Composer / Grok）は Fast を使わない**。T3 `delegate_task`
  は options 無しだと Fast で動く（2026-10-23 にダッシュボードで確認。
  UI は Fast オフと表示するが信用しない）。`target.options` に
  `fastMode: false` を**必ず**明示し、応答の `options` で確認する。
  CLI は `-fast` 無しの ID。明示せずに呼んだ場合は申請不要の範囲外
  （無許可の Fast 利用）として扱う。詳細は `docs/routing.md` §8 および
  `rules/delegation.md` §8。
- **Argon は人間直操作なら `antigravity`、エージェント実行なら `bin/argon-sub`**（§0.5）。
  cursor のカタログに `gemini-4-argon` が出るが選ばない
  （Other Models は Fable 専用）。固定表は `docs/routing.md` §4。

### 2.2 Cursor Cloud Agent（作業エージェント）

**ローカル方針と切り離す。** Cloud Agent は従来どおり:

- **設計**: Grok 4.7（**必ず非 Fast**）
- **実装**: Composer 2.5（**必ず非 Fast**）

### 2.3 Gemini 4 Hydrogen（人間直操作 `agy` / エージェント用 `hydrogen-sub`）

- **日常実装（W1）には使わない**（W1 は Codex、探索・W2・推敲等に集中させる方針を維持）。
- **設定**: `agy`（人間直操作）・`hydrogen-sub`（API）とも **既定 `high`（無指定で可）**。
  単純な機械的抽出は任意で `"low"` 可。`xhigh` は無意味な引き上げを禁止し、
  必要時のみ理由 1 行記録で事後報告可（§1.2）。
- **担当と経路の切り分け**:
  - **テキスト中心（W2 要約、一覧化、整形、推敲 yomiyasu §2.8）**: エージェントからは
    **`bin/hydrogen-sub`** を使う（単発テキスト API のため材料は親が渡す）。
  - **ツールが必要な探索・検索・PNG 目視**: `hydrogen-sub` はファイル操作・Web 検索・
    画像入力を持たず、かつ他エージェントからの `antigravity` 委譲は禁止のため、
    エージェント実行時はファイル探索・Web 検索を **`codex`（Luna / Terra）または
    `claudeAgent`（Haiku / Sonnet）**（許可タスクでは Grok 非 Fast も可）、
    Visual QA を **Grok 4.7（§2.1 非 Fast）** へ回す。人間が T3 UI で直接
    `antigravity` Hydrogen スレッドを操作する場合のみ Hydrogen に担当させてよい。
- 旧 **Gemini 3.8 Flash**（`flash-sub`）は Hydrogen が使えない旧環境等の
  レガシー控えに留める。

## 2.5 Worker（実装役）とオーケストレーション

### 司令塔

- **研究タスクのオーケストレーターは Opus 5.5（Claude Team）**。
  旧記述の Flash / Grok 司令塔は廃止。Opus が使えないときだけ §2.1 の
  **Grok 4.7 代行**（Opus 不在時に代行できるのが Grok のみ・Grok 枠は
  リセットまで長いので温存）。
- **研究以外のリポジトリ**: 本人の運用に合わせ、司令塔は Grok
  （Cursor・非 Fast）または Gemini 4 Hydrogen（旧 Flash）。以下の Opus 司令塔・
  ループ頭設計は研究の既定であり、非研究へ自動適用しない。Private の
  外部送信制約と従量課金・HPC 等の境界は維持する。

### 設計・仕様（大きなループ）

- **ループ最初に 1 回**: Opus が方向・仕様の骨子・完了条件（DoD）を決める
  （§3.6 **申請不要**）。
- **細かい仕様・実装・軽いセルフレビュー**: **Codex**。T3 のモデル・effort は
  下記の作業別選択、CLI は `codex-sub`（ChatGPT ログイン・medium）。
  スキル `codex-harness`。
- **Opus 5.5 へ上げる**: 同一タスク内で前提が崩れたとき、または
  **同じ指摘が 2 回**出たとき（§3.6 **申請不要**）。
- 上げた**回数と理由を記録**する（RES-23 の計測と合わせて見る）。

### W1 日常実装

- **実行チャネル（環境による分岐）**:
  - **T3 Code 環境（`delegate_task` が利用可能、または `com.t3tools.t3code` /
    `T3CODE_CLI_PATH` 検知時）**:
    - **第一候補**: T3 ネイティブ委譲 `delegate_task`
      （`providerInstanceId: "codex"`、モデルは下記の作業別選択）を優先使用する。
    - **設定（既定）**: `target.options` に
      `{"reasoningEffort": "medium", "serviceTier": "default"}` を指定
      （Fast 禁止）。high が承認された作業だけ `reasoningEffort` を `high` に
      変え、`serviceTier` は `default` を維持する。
    - **フォールバック**: 下記「DeepSeek API」の利用条件を満たすときだけ
      候補にする。上限・エラーだけを理由に自動で API へ切り替えない。
  - **非 T3 Code 環境（Claude Desktop Code モード / Cursor / 端末 CLI 等、
    `delegate_task` が利用できない場合）**:
    - **第一候補**: CLI ラッパー `codex-sub --repo <dir> --prompt "..."`
      （ChatGPT Plus ログイン、effort medium）。
    - **ラッパーの挙動**: `codex-sub` はCodex専用。上限・未ログイン・
      エラー・タイムアウトでは停止し、APIへ自動切替しない。DeepSeekが必要・
      許可済みなら `dsh-sub` を直接呼ぶ。スキル `codex-harness`。
- **フォールバックの許可境界（T3 / CLI 共通）**: DeepSeek API は下記
  「DeepSeek API」の条件を満たす場合だけ使う。API 禁止・特定モデル固定・
  GPT 限定・追加委譲禁止など、依頼と実行環境の制約も優先する。
  `codex-sub` 自体はAPIへ切り替えない。適合する経路がなければ停止・報告する。
- **モデル系統**:
  - ChatGPT Plus の主力は **`gpt-6.1-sol` / `gpt-6.1-terra` / `gpt-6-luna`**
    （`gpt-6-astra` は Plus には付帯しない）。
  - `codex-sub` ではモデル名を引数に固定せず、ChatGPT Plus
    ログインアカウントの既定（6.1 系列）に任せる。
  - T3 Code のネイティブ委譲は、名指し指定を優先し、指定がなければ
    作業の種類で選ぶ（2026-11-04 人間決定）。

    | Codex に任せる作業 | モデル | effort |
    | --- | --- | --- |
    | 仕様が固まった実装（生成器・テスト・既存パターンの流用） | `gpt-6.1-terra` | medium |
    | スクリプト化できる既存データの解析 | `gpt-6.1-sol` | medium |
    | 設計・計画、解釈が分かれる解析 | `gpt-6.1-sol` | high (*1) |

    (*1) 依頼前に §3.6–§3.7 の1行申請・承認が必要。名指し許可済みなら再申請不要。

  - この表は Codex 内の選択であり、ループ頭 Opus・Phase-First 等の
    既存の役割分担を変更しない。

- **Codex 子からの孫委譲**: GPT ファミリー（Sol・Terra・Luna）内だけ許可し、
  WebSearch と大量の機械的作業に使う。brief に「孫委譲しない」を既定で
  書かない。孫に使ったモデル・effort・serviceTier 等の実際の設定を子の報告に
  含めさせる。孫も `providerInstanceId: "codex"`、`serviceTier: "default"`、
  Fast 禁止・effort 既定 medium を守る。
  - 呼び出し前に `orchestrator_capabilities` で利用可能性を確認する。
    Luna は一覧に出ないことがあるため、呼べると確認できなければ使わず
    報告する（slug や設定を発明せず、指定モデルの無断代替もしない）。
  - タスク固有の追加委譲禁止・許可モデル制約、Strict Model Fidelity、
    Maker-Breaker、Private・API・Cursor Fast・HPC の禁止事項は孫にも継承する。
    GPT 孫の作業報告は独立 Breaker の代用にしない。
- **代替（控え）**: `codex` が無い・未ログイン・API キー認証・利用上限のとき
  **`dsh-sub`**（§2.5「DeepSeek API」の条件を満たすときだけ別途呼ぶ）。
- **DeepSeek Free は使わない**（W1・W2 とも。2026-11-04 人間決定）。
- 難所（W3）: 上記の条件で **Opus 5.5**（Sonnet 経路は既定から外す）。

### 敵対的レビュー

- **T1・T2・T3**: 当面**呼ばない**。Codex のセルフレビューは Maker の報告であり
  Breaker ではない。
- **Breaker**: 大きなループの**最後に Opus 5.5 を 1 回**（§3.6 申請不要）。
  **引き上げ**（前提崩れ・同指摘 2 回）も Opus 5.5。
- Maker が `dsh-sub`（フォールバック）のときも **T1 を `dsh-sub` にしない**
  （同系統の二重チェックを避ける）。
- **RES-23（〜2026-11-07）**: §0 の 5 系統を記録。Claude Team が足りなければ、
  週後半の Anthropic API 従量課金または Claude Pro 契約を検討する。

### 暫定監査（2026-11-04 人間の指示、2026-11-16 規約順守経路へ改定）

- **Claude の枠を節約するため、当面のループ末監査は Argon medium へ回す**。
  上記および他ファイルの「Breaker は Opus のみ」「Argon は発想のみ」に対する、
  この監査に限った例外。終了日や自動解除条件は設けず、人間が変更するまで適用する。
- **実行経路（重要）**: §0.5 の規約順守により、エージェントが自動委譲するときは
  `delegate_task(..., "antigravity")` や `agy -p` を**使わず**、必ず
  **`bin/argon-sub`**（API・既定 `medium`、必要材料と差分をプロンプトに渡す）を使う。
  人間が T3 UI で直接 `antigravity` Argon スレッドを開いて監査させる場合は
  サブスク枠を使ってよい。
- Maker と異なるモデル・別コンテキストで、編集を伴わない独立監査を1回行う。
  T1/T2/T3 の常設化、設計・仕様策定・実装への Argon 利用は許可しない。
  引き上げ・裁定など監査以外の Opus の役割と申請要否は維持する。
- API 禁止タスクや残高枯渇等で Argon を呼べない、または異種性・タスク制約を
  満たせない場合は停止・報告し、別モデルへ無断で切り替えない。

### DeepSeek API（`dsh-sub`）

- **利用条件（2026-11-04 人間決定）**: `dsh-sub` が必要なタスク
  （明示指定・その契約の検証など）、またはサブスク枠不足で本人が
  DeepSeek API 利用を明示した場合に限る。枠不足・未ログイン・エラーだけでは
  許可とみなさない。
- **控え**（上記条件を満たすときだけ）。`bin/dsh-sub` は残す。
  既定 `deepseek-flash` / effort `high`。難所は `deepseek-v4-pro` /
  `effort max`（常用禁止）。無料枠と混同しない。Auto-reload は OFF。
  呼び出し契約はスキル `deepseek-harness`。

## 2.8 yomiyasu（`nanaism/yomiyasu`）

- **大きなループの終わり**、人が読む文章に使う。担当モデルは
  **Gemini 4 Hydrogen**（エージェント実行時は **`bin/hydrogen-sub`** 既定 `high`、
  人間直操作時は `antigravity` Hydrogen も可）。
- 依頼文で、【事実】【解釈】【未確認】などの **【】接頭辞**、見出し、
  箇条書き、番号、数値を**変えない**よう明示する。
- 推敲後は**元文との diff** を取って確認する。
- **本体を使う**（2026-10-30 決定）。mini は使わない。RES-24 の試行は
  本体前提で継続し、品質・コストの記録だけ残す。

## 2.9 残量の使い方（ペース方針の変更）

- **「リセットの 1 週間前に使い切る」Cursor ペースはやめる**。Cursor 月枠は、
  **各周期の終わりに数 % 残して** Cloud Agent 用に確保する。
- **Gemini 週次枠・Cursor 月次枠**がリセット前に多く残っていた場合、
  **本人が明示的に呼んだときだけ**追加で使う（自動的なバーンダウンで
  消費しない）。

## 3. Claude（エージェントは Team のみ、agy は人間直操作のみ）

- **認証の確認**: `claude auth status` が `subscriptionType: "team"` なら、
  `claude` CLI と T3 の `claudeAgent` は **Team シート（サブスク）** で
  動く。従量 API ではない。
- **モデル別の置き場所**: **Sonnet 5.5** は既定経路から外す。
  **名指し**のときだけ使う。**エージェントが Opus 5.5 / Sonnet 5.5 を呼ぶ場合は
  すべて Team 枠（`claudeAgent` / `claude` CLI）** を使う。§0.5 により、
  エージェントや CLI から `agy` 経由で Claude 週枠を呼ぶことは禁止
  （人間が T3 UI で直接 `antigravity` スレッドを立てて使う場合のみ可）。
- **Team は研究優先**: dotfiles / life-brain などの生活タスクは Codex（`codex-sub`）や
  人間直操作の `antigravity` / 許可時 Cursor を使い、Team は研究タスク優先にする。
- **認証の優先順位**: Team シート > Anthropic 従量 API。
- **API に切り替わる条件**: `ANTHROPIC_API_KEY` が設定されている、または
  `CLAUDE_CODE_SIMPLE=1` を使うと従量 API になる。使う前に
  `claude auth status` と環境変数を確認する。
- **Team 枠を使い切った場合**: RES-23 の計測を見て、週後半に
  **Anthropic API 従量課金**または **Claude Pro 契約**を足すか本人が
  決める（§0・§2.5 と同趣旨）。明示指示なしに従量 API を開かない。
- Claude 特有の自走が必要な局面では Sonnet 5.5 / Opus 5.5 を Team 枠で
  使う。`claudeAgent` は `binaryPath: claude` を叩くため、CLI と同じ認証を
  共有する。T3 から Opus / Sonnet を呼ぶなら `claudeAgent` を使う
  （Sonnet は `effort: medium` を明示）。

## 3.5 effort の既定値

- 原則既定は **medium**（**Gemini 4 Hydrogen は人間直操作 `agy`・API
  `hydrogen-sub` とも既定 `high`**）。格上げは「成功条件が開いている」案件だけに使う。
- 閉じている（ルーブリック・DoD・テスト・差分がある）: medium（Hydrogen は既定 high）。
- 開いている（何が良いか自体を決める）: high（Hydrogen は xhigh 可）。
- 機械的（整形・分類・抽出）: low。ただし T3 Codex 子・孫の既定は
  medium（§2.5）。
- モデルと effort は別軸。モデルを上げる前に effort を下げられないか
  考える。
- **役割の目安**: ループ頭の設計 = Opus 5.5 high（§3.6 申請不要）/
  細部・W1・セルフレビュー = Codex（`codex-sub`）/ 控え = `dsh-sub` /
  Cloud 実装 = Composer 2.5 / 敵対レビュー = §2.5「暫定監査」を優先、
  恒久方針はループ末 Opus 5.5 / **API Hydrogen（`hydrogen-sub`・既定 `high`）**=
  テキスト W2・整形・yomiyasu（§2.8）。ツール探索は `codex`（Luna/Terra）/ `claudeAgent`、
  エージェント実行の Visual QA = Grok 4.7（非 Fast・§2.1）。
  人間直操作の `antigravity` Hydrogen も探索・Visual QA・yomiyasu に使用可。
- **effort を変えるときは新しいスレッドで始める**。同一スレッドの途中で
  変えると、それまでの履歴を読み直すうえキャッシュも効きにくい
  （Antigravity の運用知見）。
- medium と high の品質差は小さいという報告が複数ある。差の有無は
  **モック実験ではなく普段の使用感**（返答の質・トークンの減り方）で
  判断する（2026-10-21 決定）。

| provider | 無指定のときの effort | 対処 |
| --- | --- | --- |
| claudeAgent の Sonnet | **high** | `options` で medium を明示する |
| claudeAgent の Opus / Fable | medium | 明示不要。high にするときだけ書く |
| API Hydrogen (`hydrogen-sub`) / 人間直操作 `agy` | **high** | 既定 high で可（軽作業 `low`・`xhigh` 事後報告可） |
| `argon-sub` / 人間直操作 `antigravity` Argon | medium | 設定明示 (*2) |

(*2) エージェントは `bin/argon-sub`（既定 medium、API 格上げは理由 1 行記録で事後報告可）。
人間直操作 `antigravity` の Argon high や Codex の high は要申請（無意味な引き上げは禁止）。

## 3.6 許可の所在

- 呼び出し前の申請は **ファミリーと effort の格上げ** だけ。5h / 週枠の
  消費％を推定して申請しない。
- **オーケストレーターのハンドオフ**（`rules/delegation.md` §1）: 司令塔が
  `docs/routing.md` に従い Worker（W1 `codex-sub` 等）・探索・レビュアへ
  `delegate_task` / CLI で委譲するのは**本人が許可済み**。都度の申請は不要。
- **要申請**: Codex の medium から high への格上げ（依頼前に1行で申請し、
  承認を待つ。§3.7）/ Fable 5.1 / Sonnet 5.5 の high / 人間直操作 `agy` の Argon high
  （格上げ、3.7。Google API の Argon / Carbon high は §0.5 の 1 行記録で
  事後報告可）/ Anthropic・OpenAI の従量 API / **OpenAI 従量での Codex** /
  **Opus 5.5 のうち、下記「申請不要」に該当しない用途**
  （例: Phase-First の節目 Opus 5.5、発想・裁定のみの追加 Opus 5.5）。
- **申請不要**: Composer / Grok（`fastMode: false` を明示した場合のみ。§2）/
  **Google API（`gemini-sub` / `hydrogen-sub` / `argon-sub` / `carbon-sub`、
  §0.5 の事前確認済み Prepay 経路。Hydrogen 既定 `high`・軽作業 `low` 可、
  Argon / Carbon 既定 `medium`。Argon / Carbon の `high` や Hydrogen の
  `xhigh` は無意味な引き上げ禁止・理由 1 行記録で事後報告可）** /
  人間直操作 `antigravity` での Hydrogen / Argon medium /
  Sonnet 5.5 (medium)（**Team 枠・名指し時**）/
  **W1 の Codex（ChatGPT ログイン、T3 `delegate_task` または `codex-sub`）** /
  **DeepSeek API（§2.5 の利用条件を満たす場合のみ）** /
  **Opus 5.5 の次の用途**:
  - 大きなループの最初の設計（方向・仕様骨子・DoD）
  - 大きなループの最後の敵対的レビュー（1 回）
  - 同一タスク内で前提が崩れたとき、または同じ指摘が 2 回出たときの、
    **Codex（フォールバック時は `dsh-sub`）から Opus 5.5 への引き上げ**
- **依頼者がモデル/effort を名指しした場合は、その1回分の許可とみなす**
  （提案も再確認も不要。例:「Argon high で設計して」）。

## 3.7 格上げの提案（名指しされたモデルは勝手に変えない）

- 名指しされたモデル/effort でも、成功条件が開いている（設計判断・前提の
  崩壊・論文の主張）と分かっていれば、**着手前に1行**で格上げ案を出す。
- **出力が格上げ後に再利用できない作業**（判断・主張の組み立て）は、
  承認が出るまで開始しない。**例外**: §3.6 申請不要の Opus 引き上げ
  （前提崩れ・同指摘 2 回）と、申請不要のループ頭設計・ループ末レビュー。
  再利用できる作業（調査・列挙・材料集め）は medium で進めてよい。
- 提案は1行・選択肢は最大2つ・推奨を1つ。返事が無いまま次の区切りを
  過ぎたら「保留」と報告し、他の再利用可能な作業へ移る（全体は止めない）。
- 格上げ先の順序: ①同一モデルの effort 上げ（要許可。Google API・Hydrogen `xhigh` は事後報告可）
  ②前提崩れ・同指摘2回は **Opus 5.5**（§3.6 申請不要。Sonnet 5.5 high より優先）
  ③別ファミリー medium ④Fable（核ボタン・要許可）。**要申請の格上げ先は、
  承認が出るまで切り替えない。**
- 名指しモデルの変更は承認があったときだけ（Strict Model Fidelity）。
  「任せる」と言われた場合はこの限りでない。

## 4. ゴール固定・敵対レビュー

- 長作業の開始時は、Goal・成功条件・制約・Next を短く書き出してから
  着手する（`now/TODO.md` か作業ノート。専用スキルは置かない）。
- 意地悪テスト生成・敵対的監査は「Maker-Breaker原則（実装と検証は異種
  モデル・コンテキスト完全隔離）」を遵守すること。**Maker** は Codex
  （`codex-sub`、フォールバック時は DeepSeek **`dsh-sub`**）。
  **Breaker** は §2.5「暫定監査」を優先し、恒久方針はループ末の
  **Opus 5.5**（T1/T2/T3 は当面なし。**Gemini 4 Hydrogen・旧 3.8 Flash は
  敵対レビューに使わない**）。選定と詳細手順はスキル `adversarial-review` および
  `model-route` を参照。

## Typst（共通スキルの分担・実行制約）

- 共通手順は `agents/skills/typst-workflow/SKILL.md` を各エージェントが
  明示readする。
- 論旨・主張・章立ては **Opus**。確定材料からの本文下書き/修正・図表・
  体裁・テンプレ移植は **Codex medium**。
- 推敲は **`bin/hydrogen-sub`（既定 high、人間直操作なら `antigravity` Hydrogen も可）
  + yomiyasu本体**。意味・数値・引用を元文とのdiffで確認する。
- PNG目視はエージェント実行時は **Grok 4.7（非 Fast、画像判断能力は未確認）**、
  または人間が T3 UI で直接 `antigravity` Hydrogen スレッドを開いて目視する
  （エージェントからの `antigravity` 委譲は不可、§0.5）。
  同じ問題が2回なら **Opus**。ループ末の独立reviewは §2.5「暫定監査」（`bin/argon-sub`）を
  優先する（Makerの自己確認とは別）。
- T3では `delegate_task` のcodexが基本。`target.options` は
  `{"serviceTier": "default", "reasoningEffort": "medium"}`。
  CLI `codex-sub` は非T3の補助経路。
- **全Fast/priority禁止**。Claude/Cursorは `target.options.fastMode: false`
  を明示し、Codexを含め応答の `options` を確認する。GeminiはFast off設定が
  公開されていないため、勝手なoptionsを発明・実行しない。確認できない場合は
  停止して報告する。
- タスクでAPI禁止なら `codex-sub` のCodex専用経路を使い、DeepSeekへ
  切り替えない。再委譲はそのタスクで許可されたモデルのみ。CLI AI/追加委譲
  禁止も優先し、独立reviewを勝手に実行しない。
