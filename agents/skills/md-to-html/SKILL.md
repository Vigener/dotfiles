---
name: md-to-html
description: >-
  Markdownファイルを人間レビュー・実戦カンペ・印刷用の自律完結HTMLへ高速変換する。
  「mdをhtmlにして」「アジェンダをhtmlに」「カンペをhtmlに」「html化して」
  「md-to-html」で発動。dotfiles/bin/md-to-html を使用し、
  正本Markdown（SSOT）を維持したまま美麗HTMLを生成する。
---

# md-to-html

## 目的

**「正本はMarkdown（SSOT）のまま保ち、画面閲覧・スマホ確認・A4印刷用HTMLを低コストで自動生成する」**。  
毎回ゼロから HTML/CSS を書かず、汎用CLI `md-to-html` を用いて、
スタンドアロン（単一完結）なHTMLを瞬時にビルドする。

---

## 基本コマンド

```bash
# 基本形: 入力と同じ場所に .html を自動生成
md-to-html path/to/document.md

# テーマを明示（tactical / sepia / minimal / auto）
md-to-html path/to/document.md -t tactical
md-to-html path/to/document.md -t sepia

# 出力先を指定
md-to-html input.md -o output.html

# 生成後にブラウザを自動起動
md-to-html input.md --open
```

---

## テーマ選択ガイド

- **tactical** (`-t tactical`):
  - 推奨用途: 学内セミナー、カンペ、手順書、ヒアリングシート
  - 特徴: ブルー＆ダーク基調。ターミナル風コード、会話引用、A4白黒印刷CSS。
- **sepia** (`-t sepia`):
  - 推奨用途: 雑談アジェンダ、精神的幸福論、概念整理
  - 特徴: セピアダーク基調（Literata）。会話吹き出し、対比表、内省デザイン。
- **minimal** (`-t minimal`):
  - 推奨用途: 論文メモ、公式資料、白背景の配布用ドキュメント
  - 特徴: GitHubライクな白背景・クリーン。
- **auto** (`-t auto`, 既定):
  - 迷ったとき。本文内容からキーワードを解析し、最適なテーマを自動選択。

---

## 運用ルール（AIエージェント向け）

1. **正本は絶対にMarkdownのまま維持する**:
   - 内容の加筆・修正・削除は必ず `.md` ファイルに対して行う。
   - `.html` はビルド成果物（使い捨て・自動再生成可能）として扱う。
2. **生成後の確認（open-artifact連携・環境分岐）**:
   - 文書編集しただけで無条件にブラウザを開かない。
   - **T3 Code 環境**: 画面確認を求められた場合は実ツール
     （`html_preview` → `html_render`）または絶対パスリンクで提示する。
     投稿・配布用 PNG や論文図は元のファイル成果物を保持し、
     `html_render` で代替しない。
   - **外部ブラウザ閲覧**: ユーザーから外部 MBA Chrome での確認を
     明示された場合、または T3 外環境でのみスキル `open-artifact` の
     外部配信フローに委譲する。
   - 古い `:8770` ポートや直接の `ssh mba "open ..."` は使用しない。
3. **印刷対応**:
   - `tactical` テーマ等は `@media print` に対応しているため、
     ブラウザ印刷（Cmd+P）で即座にA4用紙やクリップボード用の白黒
     レイアウトになる。

---

## 関連

- 汎用スクリプト: `dotfiles/bin/md-to-html`（`~/.local/bin/md-to-html`）
- `human-review-html`: ゼロから静的HTMLを作る場合のトーン選択表
- `open-artifact`: 生成したHTMLをブラウザで開く
