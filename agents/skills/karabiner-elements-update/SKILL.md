---
name: karabiner-elements-update
description: >-
  dotfilesのKarabiner-Elements設定（主にアプリ起動やキーマッピング等）を更新し、READMEを同期し、ビルドを実行して完了するスキル。
  「Karabinerに〇〇を追加して」「かなキー+Xを〇〇に割り当てて」「メインブラウザをXXに変更して」といった指示で発動する。
---

# karabiner-elements-update

## Overview

`dotfiles/karabiner/` 以下の Karabiner-Elements 構成を更新するための専用スキル。
特に頻繁に変更される `launcher.ts` の構造を理解し、最小限のトークン消費で安全に設定を追加・変更する。
更新後はビルドを実行し、人間向けの `README.md` を同期して作業を完了させる（Gitコミット・プッシュは行わない）。

## 🎯 ワークフロー

### 1. 変更要件の確認とバンドルIDの特定
追加・変更するアプリケーションのバンドルID（Bundle ID）が必要な場合は、以下のコマンドで特定する。
```bash
osascript -e 'id of application "アプリ名"'
# または
find /Applications -maxdepth 3 -iname "*アプリ名*.app" | xargs ...
```

### 2. 設定ファイルの更新
Karabiner の設定ファイル群は `dotfiles/karabiner/rules/` にある。

#### 🗺 アーキテクチャ早見表
| ファイル | 役割 | 更新頻度 |
|---|---|---|
| `launcher.ts` | かなレイヤー・アプリ起動 | **最頻繁** |
| `window.ts` | かなレイヤー・ウィンドウ管理 | 低 |
| `edit.ts` | 英数レイヤー・編集操作 | 低 |
| `sys.ts` | 英数/かなキーのモディファイア化 | ほぼ触らない |
| `app.ts` | アプリ固有ルール (Vivaldi, Warpなど) | 低 |
| `README.md` | マッピング表 (人間向け仕様書) | 上記と常に同期 |

#### 🔧 `launcher.ts` の変更ルール（重要）
アプリの起動設定を変更する場合は、主に `launcher.ts` を編集する。

1. **アプリの追加/削除**
   - まず `APP_REGISTRY` オブジェクトに `"アプリ名": "^バンドルID$"` のエントリを追加する。
     - **ルール**: 使わなくなったアプリ（一軍落ち）も `APP_REGISTRY` からは **絶対に削除しない**。将来の再利用に備え、資産として残しておく。
   - 次に、`launcherRules` 配列内の適切な箇所に `...toggleApp("キー", "アプリ名")` を追加する。
2. **ブラウザの変更**
   - メインブラウザを変更する場合は、ファイル上部の定数 `MAIN_BROWSER`, `BROWSER_HUB_TAB`, `BROWSER_AGENT_TAB` を変更するだけでよい。
3. **キーの付け替え**
   - `launcherRules` 内の `...toggleApp("キー", "アプリ名")` の第一引数を変更する。

### 3. README.md の同期
設定を追加・変更・削除した場合は、必ず `dotfiles/karabiner/README.md` の「マッピング表」を同期する。
対象の表（例: `### APP（かなレイヤー）` の `#### アプリ起動`）を見つけ、整合性がとれるようにマークダウンのテーブルを更新する。

### 4. ビルドの実行と確認
変更が終わったら、以下のディレクトリでビルドコマンドを実行し、エラーがないか（Profile が更新されるか）確認する。
```bash
cd dotfiles/karabiner/
npm run build
```

※ビルドが成功したら、ユーザーにその旨を報告してタスク完了とする。
