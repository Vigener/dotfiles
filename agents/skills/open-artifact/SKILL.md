---
name: open-artifact
description: >-
  成果物HTMLの確認・提示を行うスキル。
  T3 Code環境内では外部配信は不要
  （html_preview → html_render、または絶対パスリンク）。
  外部MBA Chromeを明示して開く場合やT3外環境でのみ
  従来の外部配信（http-brain / ssh mac）を使う。
  Plan/goal締めの自動発動は行わない。
  「ブラウザで開いて」「MBAで開いて」「open-artifact」等で発動。
---

# open-artifact

成果物 HTML の確認・提示手順。

> [!IMPORTANT]
>
> - **T3 Code 環境**: 外部配信（HTTP / SSH）は不要。HTML 表示はツールが
>   あるとき `html_preview` → `html_render`、ファイル参照は絶対パスリンク
>   `[名前](/Users/.../path)` で提示する。差分や Markdown で足りる場合は
>   HTML 自体の生成も不要。文書編集だけで無条件にブラウザを開かない。
> - **外部表示（MBA Chrome）**: ユーザーが外部ブラウザ閲覧を明示指定した場合、
>   または T3 外環境のときだけ使用する。

## 1. T3 Code 環境での提示

T3 Code 内で完結する場合、Web サーバ起動や SSH 転送は行わない。

- **HTML プレビュー**: ユーザーが画面確認を求めた場合、利用可能な T3 ツール
  （`html_preview` → `html_render`）に HTML の内容を渡して表示する。
- **ファイル共有**: チャット内では絶対パスの Markdown リンク
  （例: `[成果物](/Users/mikoto/.../topic.html)`）を示す。
- **実ツールの確認**: 実際に利用可能なツールのみを呼び出し、存在しない
  オプションや能力を捏造しない（表示要求がない文書編集ではプレビュー呼び出し
  自体不要）。

## 2. 外部 MBA Chrome での閲覧手順（明示指示時・T3 外）

ユーザーが「MBA で開いて」など外部端末での閲覧を明示した場合、または T3 外で
閲覧を求められた場合のみ実行する。
T3 内で単に「ブラウザで確認したい」と言われた場合は、外部 MBA 起動の
指定とは扱わず、実行環境のブラウザ操作契約に従う。

```text
1. 人間向け成果を HTML として保存（wiki/ 配下など）
2. Tailscale IP で URL を組み立てる
3. ssh mac 経由で Chrome を開く（または停止フックに委譲）
```

### URL 組み立てと配信確認

- `~/brain/research-brain/wiki/...`: http-brain :8766
  （`http://<TS_IP>:8766/wiki/...`）
- sandbox 配下: http-sandbox :8765
  （`http://<TS_IP>:8765/<相対パス>`）
- 上記以外: `thinkpad-resident status` 出力にあるポートを使用

```bash
TS_IP="$(tailscale ip -4 | head -n1)"
REL="wiki/ai-engineering/example.html"
URL="http://${TS_IP}:8766/${REL}"

# 配信サイトが未起動の場合のみ起動
thinkpad-resident status
# 対象サイトが未起動と確認できた場合のみ（sandbox は http-sandbox）
thinkpad-resident start http-brain
```

### ブラウザ起動（3a または 3b のいずれか）

- **今すぐ開く（3a・既定）**:

  ```bash
  ssh -o BatchMode=yes -o ConnectTimeout=5 mac \
    "~/dotfiles/bin/chrome-open-or-reload '$URL'" || true
  echo "$URL"
  ```

  ※ MBA オフライン等で接続失敗してもエラーで中断せず、
  URL をチャットに提示する。

- **セッション末に開く（3b・opt-in）**:

  ```bash

  printf '%s\n' "$URL" > ~/.cursor/open-on-stop.url
  ```

## 3. スマホ通知（ntfy）

ユーザーが「ntfy」「通知して」と明示した場合のみ送信する（常時併送しない）。

```bash
~/bin/ntfy-notify "タイトル" "本文" "$URL"
```

- **制約**: スマホで開く URL は必ず `.html`（`.md` は文字化け・極小表示と
  なるため `ntfy-notify` が拒否する）。

## 4. やらないこと

- Plan / goal 締めでの無条件自動オープン（明示指示がない限り開かない）
- T3 Code 環境内での不要な HTTP サーバ起動や `ssh mac` 実行
- 素の `python -m http.server` の起動
- URL のドキュメントへのハードコード（Tailscale IP を固定しない）

## 関連スキル

- `human-review-html`: 人間レビュー用 HTML テンプレートのトーン選択
- `md-to-html`: Markdown からスタンドアロン HTML への変換
- `update-agent-config`: 挙動設定変更時の層判定
