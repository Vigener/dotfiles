# 成果物・ログの配置

## 1. 作業ログと README の分離

- 作業中（計画立案・エラー対応・試行錯誤）のログは、プロジェクト内の `logs/` または `docs/logs/` に隔離して保存・追記する。プロジェクトのルートはクリーンに保つ。
- `README.md` には試行錯誤の過程を書かず、「最終結果」と「根幹部分」だけをまとめる。

## 2. 成果物と図表

- 成果物（レポート PDF、概観用・提出物系の Markdown）はプロジェクトルートに置く。
- 図表（画像等）はプロジェクトルートの `images/` に保存する。

## 3. エージェント間 vs 人間レビュー（2026-07-31 取り決め）

詳細手順はスキル `open-artifact` / `update-agent-config`。

1. **エージェント間・中間成果**: Markdown / 構造化テキスト（差分・grep・機械可読を優先）。`inbox/`・`logs/`・作業ノート。
2. **人間レビュー・保存版概念解説**: HTML（`wiki/`）。フォーマットガイド: `research-brain/.agents/references/wiki_formatting_guide.md`。
3. **セッション終了時（best-effort）**: 人間向け HTML を更新したら `open-artifact` スキルに従い、MBA でブラウザを開く（`ssh mac 'open URL'`）。オフライン時の失敗は無視して URL をチャットに出す。
4. **配信**: 母艦（**mini**）の `http-brain`（:8766）等。素の `python -m http.server` 禁止（`thinkpad-resident`）。略称は `glossary.md`。
5. **挙動設定の変更**: 必ず `update-agent-config` で層（Context / Harness / Loop / Graph A/B）を判定してから最小変更する。
