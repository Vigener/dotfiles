# Global AI Agent Rules

このファイルは、どのディレクトリにいる場合でも利用できる汎用的なAIエージェントのルールとスキルの案内です。

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
4. **配信**: Thinkpad の `http-brain`（:8766）等。素の `python -m http.server` 禁止（`thinkpad-resident`）。
5. **挙動設定の変更**: 必ず `update-agent-config` で層（Context / Harness / Loop / Graph A/B）を判定してから最小変更する。
</RULE[artifact_handoff_html]>
