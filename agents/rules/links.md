# リンク記法・ポータビリティ（2026-09-26）

Ghostty CLI 等での閲覧性と、SMB 経由（MBA）での Obsidian 閲覧ポータビリティを保証する。

## 1. チャット回答文

- ホスト絶対パスの `file:///...` リンクは一切出力しない（クリック不可で視覚的ノイズになる）。
- ファイルに言及するときは、相対パス（例: `notes/lecture-outline.md`、`wiki/hpc/foo.md`）またはファイル名のみ。
- ブラウザで開く成果物（HTML 等）だけ、`http://mikotomac-mini:8766/...`（または Tailscale URL）で示す。

## 2. ファイル内リンク

- リポジトリ内のファイル（`.md` / `.html` 等）に、ホスト固有の絶対パス（`file:///Users/...` 等）を書かない。
- 必ず相対パス（`./path/to/file.md`、`../notes/file.md`）または Obsidian WikiLink（`[[filename]]`）を使う。MBA 側から SMB 共有経由で開いたときにリンク破損・外部警告が出るのを防ぐ。
