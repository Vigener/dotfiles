# 本スレッドの引き継ぎ（2026-11-04）

> **注意（履歴・非規範）**:
> 本書は 2026-11-04 〜 2026-11-05 時点での引き継ぎ事項と実装作業を記録した**過去資料（非規範）**です。
> 現在の有効な指示・契約・割当の正本は `agents/rules/models.md`、`agents/rules/delegation.md`、
> および `agents/docs/routing.md` を参照してください。
> 本書内の「未commit」「次の焦点」「未設定」等の記述は当時の進捗メモであり、
> 現行の規範的な指示や契約事実を規定するものではありません。

Codex残量不足のため、人間が研究タスクでもGrokまたはGemini Flashへの司令塔移行を明示許可。親スレッドをAntigravity / Gemini 3.8 Flash / mediumへ切り替える。新しいトップレベルスレッドや子を作る必要はない。

## 目的・制約

- dotfiles内のモデル委譲方針を整理する差分案。commit・push禁止。変更はdotfiles内だけ。他スレッドへのメッセージ、機密の読み書きは禁止。最初にgit statusを確認し、他スレッドのautohotkey配下の変更は触らない。
- 人間はハーネスを薄くしたい。事実を複写せず正本を参照する。参考画像の趣旨はモデル向け回避策を棚卸し、契約・権限・境界は維持すること。

## 完了済み（未commit）

- agents/docs/codex-delegation-proposal-2026-11-04.md に元の行番号付き一覧、変更理由、履歴、最新の決定を記録。過去節の「未解決」「自動fallback」は履歴なので最新節と実装を優先。
- model-routeは71→31行。具体的モデル表・設定・Typst役割を再掲せず、models/routing等へ参照。Codex作業別表はmodels.md §2.5の1か所。
- T3 Codex: 確定実装Terra medium／既存データのスクリプト解析Sol medium／設計・計画・解釈が分かれる解析Sol high（依頼前の申請必要）。default tier・Fast禁止。GPT内の孫は探索・大量機械作業に可、Luna利用可能性を確認、モデル・設定報告。
- ループ末監査は人間の暫定指示でArgon medium。モデル違い・独立context・read-only維持。設計・裁定・Opus引き上げの役割は変えない。関連文書へ例外参照を同期。
- 非研究の司令塔はGrok（非Fast）かFlash。研究の通常既定はOpusだが、このスレッドは今回の明示例外。
- DeepSeek Freeは使わない。APIはdsh-sub必須の場面、または枠不足で人間が明示したときだけ。
- 人間の明示許可でbin/codex-subからAPI自動fallbackを削除。Codex専用で失敗JSONとexit 3、timeout exit 4。キー除去・medium・モデル無指定を維持。bin/tests/codex-sub.test.cjs の偽実行テスト通過（実API・実認証を使わない）。node --check、git diff --check通過。quick_validateはPyYAML不足で実行不可。
- ArgonとGrokで軽量化の独立意見を取得済み。実装後の変更全体に対する最終監査は未実施。新たな監査は新delegate_task。高effortは無断で使わない。

## Google APIの現状（次の焦点）

- 人間はGoogle AI Pro付与のCloudクレジット約70ドルを保有し、Gemini APIに最低5ドル相当をチャージ済み。画像で前払800円、Auto-charge OFF、対象My Project 41337、GCPクレジット約1.1万円を確認。実アカウント・秘密は読んでいない。
- 人間の希望: サブスク優先。該当モデルweekly limit到達時のGoogle API low/mediumは申請不要。highへの格上げは従来の事前申請を維持。未設定の課金・チャージを勝手に変えない。models.md §0.5に案を記載。
- T3のAntigravity設定画面はSign-in methodがGoogle account / Gemini Enterprise / Gemini API key / Agent Platformの択一。専用API key欄あり。同プロバイダ別接続の作成は確認できていない。
- 接続全体をAPI keyへ切り替えるとFlashの残っているサブスク枠もAPIに流れうるため、既存AntigravityはGoogle accountのままに保ち、API専用の別実行経路を用意する方針で合意。
- API用経路はまだ作成・接続・試験していない。APIキーがT3へ登録済みかも未確認。キー名案t3-mac-mini-gemini-api。キーをチャットへ貼らせない。秘密が必要ならT3 request_secretの専用UIを使うが、既存の機密読み書き禁止との範囲を守る。

## Google APIの進捗（2026-11-05 実装・検証完了）

- **別実行経路 `bin/gemini-sub` の新設**:
  - T3 CodeのAntigravity（Google accountサブスク）の認証を一切汚さず、weekly limit到達時や明示指定時のみ呼び出せるゼロ依存（Node.js標準組み込みfetch）のCLIラッパー。
  - **環境変数・キーの置き場と隔離性**:
    - キーの探索順: `GEMINI_SUB_API_KEY`（専用環境変数） → `GEMINI_API_KEY` → `--key-file` → `~/.config/gemini-sub/.env`（パーミッション600） → `~/.gemini-sub/.env`。
    - グローバルな `.zshrc` 等への export を行わないことで、T3 Code / Antigravity が意図せず API キーを拾ってサブスク枠から API 課金へ引きずり込まれるリスクを完全に排除。
  - **安全弁（models.md §0.5 準拠）**:
    - 既定 medium（thinkingLevel / thinkingBudget 双方に対応）。low 可、high は事前申請が必要。
    - Prepay枯渇（429 / RESOURCE_EXHAUSTED）時や認証エラー（401/403）時は即座に exit 3 (`USAGE_LIMIT` / `AUTH_FAILED`) で停止し、Postpayへの自動移行や課金設定変更は一切行わない。
    - タイムアウトは exit 4 (`TIMEOUT`)。
  - **テスト通過**:
    - `bin/tests/gemini-sub.test.cjs`: 引数解析、キー解決、dry-run、思考マッピング、モックfetchによる429枯渇・401エラー・タイムアウト全件通過。
    - `bin/tests/codex-sub.test.cjs` との並行実行もすべてパス。
  - **ルール同期**:
    - `agents/rules/models.md` §0.5 に認証隔離と `bin/gemini-sub` の位置づけを追記。
    - `agents/docs/routing.md` のチャネルに `gemini-sub` を追記。

## 触った範囲

agents/rules/{models.md,delegation.md,cursorrules}、agents/docs/routing.md、agents/skills/{model-route,codex-harness,deepseek-harness,adversarial-review,update-agent-config}/SKILL.md、レビュー資料、bin/{codex-sub,gemini-sub}、bin/tests/{codex-sub.test.cjs,gemini-sub.test.cjs}。この引き継ぎ資料も更新。GLOBAL_RULESは未編集。autohotkeyは他スレッドの差分。
