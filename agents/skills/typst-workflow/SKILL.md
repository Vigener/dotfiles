---
name: typst-workflow
description: Typst 0.15.0の文書・テンプレートをPDFとページ別PNGに組版し、画像で日本語・数式・図表・参照・体裁を確認する共通手順。
---

# Typst workflow

1. **明示read**: Claude/Codex/Gemini/Cursorの全てで、作業前にdotfilesの `agents/skills/typst-workflow/SKILL.md` を Read / read_file / shellの `cat` 等で実際に読む。自動発見だけで本文読了とみなさない。Codexは `$typst-workflow`、Claude/Cursorはスキル名を指示してもよいが、未登録なら正本ファイルを直接読む。Geminiも同じ正本を直接読む。インストールは必須ではない。
2. PATHの `typst --version` を確認（0.15.0）。見つからなければ `mise which typst` / `mise exec typst@0.15.0 -- typst --version` で探索。未導入ならインストール権限・接続条件を確認する。helperはPATH→mise探索し、別バージョンでは停止する。
3. `typst fonts`（追加ディレクトリは `typst fonts --font-path "<font-dir>"`）で日本語fontを確認。Hiragino Sans / Noto Sans CJK JP / IPAexGothic等の実在familyを `#set text(font: ...)` に設定。無ければプロジェクトのfontsディレクトリへ利用可能な日本語フォントを追加して `--font-path` で指定する（ライセンス・ネット条件を守る）。未知font警告を解消し、PNGで豆腐・欠けを確認する。
4. プロジェクトroot（共有import/assetsを含む範囲）を決め、次を実行する。パスは引用する。
   ```sh
   "$HOME/dotfiles/bin/typst-render" "<project>/report.typ" --root "<project>" --output-dir "<project>/scratch/typst" --ppi 144
   # PNGだけ絞る場合: --pages "1,3-5"（PDFは常に全体）
   # 追加フォント: --font-path "<font-dir>"（複数回指定可）
   ```
   helperはPDF/PNGをTypstから直接生成（PDF変換ツール不要）。各実行は新しい `typst-run-*` ディレクトリに保存し、成功時のみ絶対パスJSONを返す。失敗時はその実行の一時出力を消し非zero終了。以前の成功出力は履歴であり、最新成功と誤認しない。ページ減少・選択変更でも新ディレクトリ内に旧PNGは混じらない。無関係ファイルは消さない。
5. **実際に画像を読む**: JSONのPNGを Read（画像対応）/ `view_image` / 利用環境の画像入力で開く。通常は全ページ、指定ページの場合は確認範囲を明記。日本語・数式・図表・参照・改ページ・重なり・余白を確認し、修正後は再実行した新しいパスを読む。画像ツールがなければ目視未実施と報告する。compile成功だけで目視合格にしない。チャットでは絶対パスで `![ページ](<絶対PNGパス>)` と `[PDF](<絶対PDFパス>)` を示す。

物理記法はまず既存import/macrosを検索する。このrepoの `typst/report.typ` は `@preview/physica:0.9.8` を直接importし `ket` / `bra` / `braket` を使っている（template.typでのimportではない）。既存physicaを自然に使い、バージョンを保持し、同名macroを再定義しない。

通常のsmokeは `assets/smoke.typ`（package importなし、ネット不要、2ページ）。`assets/physica.typ` は別確認で、physica 0.9.8のキャッシュまたはネット接続が必要。ネット禁止時はキャッシュを確認し、無ければ別確認を未実施とする。

通常は一回compileする。watchはユーザー希望時のみforegroundまたは追跡可能なsessionで実行し、PID/sessionを記録、終了時に停止する。helperにwatchモードはない。

上のコマンドは任意の作業ディレクトリから呼べる。dotfilesの配置が異なる場合は実際のclone先へ置き換える。helperのmise探索は現在有効なバージョンを使うため、0.15.0以外なら `mise exec typst@0.15.0 -- "$HOME/dotfiles/bin/typst-render" ...` で実行する。`mise which typst@0.15.0` は使わない（whichの引数は実行ファイル名）。

生成先のscratchは各プロジェクトのgitignore対象にし、履歴が不要になったら人間が整理する。helperは過去の成功ディレクトリを自動削除しない。

分担・委譲制約は `../../rules/models.md` の「Typst」を読む。独立レビューの実施可否と実際の目視担当を報告し、API/CLI AI/追加委譲禁止時は呼ばない。
