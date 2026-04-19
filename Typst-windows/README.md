# Typst レポートテンプレート

## 📁 このディレクトリについて

Typstで大学レポートを書くための汎用テンプレートを保管しています。

## 🚀 使い方

### 方法1: `mise` タスクを使う（推奨）

どのディレクトリからでも以下のコマンドでテンプレートを利用できます。

#### カレントディレクトリにテンプレートをコピー

```bash
mise run copy-typst-template
```

`report_template.typ` という名前でコピーされます。

#### ファイル名を指定して新規レポートを作成

```bash
mise run new-typst-report -- 202310970_04_report.typ
```

指定したファイル名でテンプレートがコピーされます。

#### タスク一覧を確認

```bash
mise tasks
```

### 方法2: 直接コピー

```bash
cp ~/dev/github.com/Vigener/win-env/Typst/report_template.typ .
```

## 📝 テンプレートの特徴

- **自動脚注化**: URLリンクを自動的に脚注に変換
- **重複防止**: 同じURLは1つの脚注にまとめる
- **見出し番号**: 自動的に「1」「1.1」「1.1.1」形式
- **日本語対応**: 両端揃え、段落字下げなど
- **豊富なサンプル**: リスト、表、数式、画像、コードブロック

## 📚 レポート作成の流れ

1. **テンプレート取得**
   ```bash
   mise run new-typst-report -- my_report.typ
   ```

2. **編集**
   - タイトル、学籍番号、氏名を変更
   - 本文を執筆

3. **PDF生成**
   ```bash
   typst compile my_report.typ
   
   # または自動監視モード
   typst watch my_report.typ
   ```

## 🔧 mise タスクの設定

`~/.config/mise/config.toml` に以下が設定されています：

```toml
[tasks.copy-typst-template]
description = "Typstレポートテンプレートをカレントディレクトリにコピー"
run = "cp ~/dev/github.com/Vigener/win-env/Typst/report_template.typ ."

[tasks.new-typst-report]
description = "新しいTypstレポートを作成（使い方: mise run new-typst-report -- myreport.typ）"
run = '''
#!/bin/bash
FILENAME="${1:-report.typ}"
cp ~/dev/github.com/Vigener/win-env/Typst/report_template.typ "$FILENAME"
echo "✓ $FILENAME を作成しました"
ls -lh "$FILENAME"
'''
```

## 📖 参考資料

- [Typst公式ドキュメント](https://typst.app/docs/)
- [Typst GitHub](https://github.com/typst/typst)

## 📝 テンプレートの更新

テンプレートを更新した場合は、このディレクトリの `report_template.typ` を編集してください。
次回 `mise run` 実行時に新しいバージョンが使用されます。
