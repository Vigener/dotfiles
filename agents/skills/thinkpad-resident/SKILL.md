---
name: thinkpad-resident
description: >-
  ThinkPad で HTTP サーバや Cursor My Machines worker を正しく起動・常駐させる。
  「このディレクトリを localhost で開きたい」「HTTP サーバー立てて」「python -m
  http.server」「再起動後の resident」「http-brain / http-sandbox」など、
  一時ディレクトリ（~/tmp 等）含む任意パスの配信依頼で使う。素の
  python -m http.server は使わず repo-http-serve / thinkpad-resident に寄せる。
---

# Thinkpad resident

## 原本

`~/brain/research-brain/wiki/compute-environments/thinkpad-resident.md`

## 核心（ユーザー意図）

ワークスペースが `~/tmp` でも `~/projects/foo` でもよい。  
「この中の HTML をブラウザで見たい」と言われたら、**カレントで素の `python -m http.server` を始めない。**

必ず `repo-http-serve`（または登録済みなら `thinkpad-resident`）を使う。
このスキルの仕事はサーバを立てて URL を返すまで。ブラウザで開くのは `open-artifact` スキル。

## A/B の選び方（機械的）

配信したい DIR が `research-brain` なら A で `http-brain`、`hybrid-workflow-sandbox` なら A で `http-sandbox`。
それ以外の DIR はすべて B。

### A. 登録済みサイト

例: `http-sandbox` (:8765), `http-brain` (:8766), worker `sandbox` / `brain`

```bash
thinkpad-resident start http-brain
```

### B. 未登録・一時ディレクトリ（例: `~/tmp/docs/index.html`）

**sites/*.conf は必須ではない。** その場の tmux + `repo-http-serve` でよい。

1. 配信ルートを絶対パスにする（例: `~/tmp/docs` → `/home/mikoto/tmp/docs`）
2. セッション名は短く一意に（例: `http-tmp-docs`）
3. 以下を1ブロックで実行する（ポート選択・起動・URL 出力まで。8765/8766 は候補に入れない）:

```bash
DIR="/home/mikoto/tmp/docs"   # 絶対パス
NAME="http-tmp-docs"
for PORT in 8770 8771 8772 8773 8774; do ss -ltn | grep -q ":$PORT " || break; done
tmux has-session -t "$NAME" 2>/dev/null && NAME="${NAME}-$PORT"   # 既存セッションは殺さない
tmux new-session -d -s "$NAME" \
  "exec $HOME/bin/repo-http-serve --dir $(printf %q "$DIR") --port $PORT --name $(printf %q "$NAME")"
echo "Thinkpad 上: http://127.0.0.1:$PORT/"
echo "Mac から:   http://$(tailscale ip -4 | head -n1):$PORT/"
```

4. echo された2つの URL をそのままユーザーに返す。
   ファイルが `index.html` なら `/` のまま、他のファイルはファイル名をパスに付ける。

5. 止め方: `tmux kill-session -t "$NAME"`（このターンで自分が作ったセッションに限る）  
   （登録サイトなら `thinkpad-resident stop <name>`）

何度も使う・reboot 後も自動で上げたい → そのとき初めて `sites/<name>.conf` を追加（wiki 参照）。

## 禁止

- `python3 -m http.server` / `python -m http.server` を直接常駐手段にする
- `--bind 127.0.0.1` だけにして Tailscale から見えなくする（既定の `repo-http-serve` は `0.0.0.0`）
- 既に使っている 8765/8766 を確認なしで潰す
- 自分がこのターンで作っていない tmux セッションへの `tmux kill-session`

## 登録サイトの操作（要約）

```bash
thinkpad-resident status
thinkpad-resident start              # AUTO_SITES
thinkpad-resident start http-brain
thinkpad-resident stop http-sandbox
```
