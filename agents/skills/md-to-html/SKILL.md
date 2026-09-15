---
name: md-to-html
description: >-
  Markdownファイルを人間レビュー・実戦カンペ・印刷用の自律完結HTMLへ高速変換する。
  「mdをhtmlにして」「アジェンダをhtmlに」「カンペをhtmlに」「html化して」「md-to-html」で発動。
  dotfiles/bin/md-to-html を使用し、正本Markdown（SSOT）を維持したまま美麗HTMLを生成する。
---

# md-to-html

## 目的

**「正本はMarkdown（SSOT）のまま保ち、画面閲覧・スマホ確認・A4印刷用HTMLを低コストで自動生成する」**。  
毎回ゼロから HTML/CSS を書かず、汎用CLI `md-to-html` を用いて、スタンドアロン（単一完結）なHTMLを瞬時にビルドする。

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

| テーマ名 | コマンド指定 | 推奨用途 | トーン・特徴 |
|---|---|---|---|
| **tactical** | `-t tactical` | 学内セミナー、カンペ、手順書、ヒアリングシート | ブルー＆ダーク基調。ターミナル風コード、会話引用、A4白黒印刷CSS完備。 |
| **sepia** | `-t sepia` | 雑談アジェンダ、精神的幸福論、概念整理 | セピアダーク基調（Literata）。会話吹き出し、対比表、落ち着いた内省デザイン。 |
| **minimal** | `-t minimal` | 論文メモ、公式資料、白背景の配布用ドキュメント | GitHubライクな白背景・クリーン。 |
| **auto**（既定） | `-t auto` | 迷ったとき | 本文内容からキーワードを解析し、自動で最適なテーマを選択。 |

---

## 運用ルール（AIエージェント向け）

1. **正本は絶対にMarkdownのまま維持する**:
   - 内容の加筆・修正・削除は必ず `.md` ファイルに対して行う。
   - `.html` はビルド成果物（使い捨て・自動再生成可能）として扱う。
2. **生成後の確認・連携**:
   - HTMLを生成したら、`sim.html` や関連ドキュメントからのリンクを `.html` に設定する。
   - Mac環境なら `open path/to/file.html` を案内し、ユーザーが快適にブラウザで確認できるようにする。
3. **印刷対応**:
   - `tactical` テーマ等は `@media print` に対応しているため、ブラウザ印刷（Cmd+P）で即座にA4用紙やクリップボード用の白黒レイアウトになる。

---

## 関連

- 汎用スクリプト: `dotfiles/bin/md-to-html`（`~/.local/bin/md-to-html`）
- `human-review-html`: ゼロから静的HTMLを作る場合のトーン選択表
- `open-artifact`: 生成したHTMLをブラウザで開く
