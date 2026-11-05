# 成果物・ログの配置

## 1. 作業ログと README の分離

- 作業中（計画立案・エラー対応・試行錯誤）のログは、プロジェクト内の `logs/` または `docs/logs/` に隔離して保存・追記する。プロジェクトのルートはクリーンに保つ。
- `README.md` には試行錯誤の過程を書かず、「最終結果」と「根幹部分」だけをまとめる。

## 2. 成果物と図表

- 成果物（レポート PDF、概観用・提出物系の Markdown）はプロジェクトルートに置く。
- 図表（画像等）はプロジェクトルートの `images/` に保存する。投稿・配布用 PNG や論文図はファイル成果物として保持し、プレビュー機能で代替・破棄しない。

## 3. エージェント間 vs 人間レビュー（2026-07-31 取り決め）

詳細手順はスキル `open-artifact` / `update-agent-config`。

1. **エージェント間・中間成果**: Markdown / 構造化テキスト（差分・grep・機械可読を優先）。`inbox/`・`logs/`・作業ノート。T3 Code では人間レビューでも差分や Markdown で足りれば HTML を強制しない。
2. **人間レビュー・保存版概念解説**: HTML（`wiki/`）。フォーマットガイド: `research-brain/.agents/references/wiki_formatting_guide.md`。
3. **閲覧・提示**: T3 Code 内では必要時に実ツール（`html_preview` → `html_render`）または絶対パスリンクで提示する。文書編集だけで無条件にブラウザを開かない。外部 MBA Chrome での閲覧を明示された場合のみ `open-artifact` スキルに従う。
4. **外部配信**: 外部閲覧時は母艦（**mini**）の `http-brain`（:8766）等を使用。素の `python -m http.server` 禁止（`thinkpad-resident`）。略称は `glossary.md`。
5. **挙動設定の変更**: 必ず `update-agent-config` で層（Context / Harness / Loop / Graph A/B）を判定してから最小変更する。

## 4. コミット

スキルは置かない（モデルの既定動作で足りる）。次の3つだけ守る。

- **意味で分割する**（1コミット1関心事）。無関係な整形を混ぜない。
- **`git add -A` を使わない**。パスを明示して stage する（相手の作業中データを巻き込まない）。
- **push は明示指示があるときだけ**（「push」「上げて」「リモートに」）。
