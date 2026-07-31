---
name: open-artifact
description: >-
  人間レビュー向け HTML（や同等の成果物）を Thinkpad の http-brain 等経由で MBA の
  ブラウザに開く。HTML を書き終えた・「成果物を開いて」「Mac でプレビュー」等で発動。
  失敗は best-effort（オフライン時の Deny は無害）。素の python -m http.server は使わない。
---

# open-artifact

## 前提（2026-07-31 取り決め）

- Thinkpad 母艦で `http-brain`（`:8766` → `~/brain/research-brain`）は **tmux 常駐**。reboot 後も AUTO 起動する想定。
- 人間レビュー用の保存版は **HTML**。エージェント間の中間成果は **Markdown**（詳細は `update-agent-config` / wiki フォーマットガイド）。
- MBA オフラインや SSH 失敗時はコマンドが Deny/失敗するだけでよい。セッション全体を失敗扱いにしない。

## いつ発動するか

1. 人間レビュー向け `.html` を新規作成・大きく更新したセッションの**終了直前**（デフォルトで best-effort）
2. ユーザーが「開いて」「Mac で見て」「プレビュー」等と言ったとき
3. `/add-to-todo` で HTML を登録した直後（任意）

## 手順

### 1. パス → URL を決める

| ローカルパス（Thinkpad） | サイト | URL |
|--------------------------|--------|-----|
| `~/brain/research-brain/wiki/...` | `http-brain` :8766 | `http://<TS_IP>:8766/wiki/...` |
| `~/projects/sandbox/...` 等 | `http-sandbox` :8765 等 | `thinkpad-resident` / wiki に従う |

```bash
# Tailscale IPv4（ハードコード禁止。変動しうる）
TS_IP="$(tailscale ip -4 | head -n1)"
# 例: research-brain 配下
REL="wiki/ai-engineering/loop-and-harness-engineering.html"
URL="http://${TS_IP}:8766/${REL}"
```

`REL` は `~/brain/research-brain/` からの相対パス。先頭スラッシュなし。

### 2. （任意）http-brain 生存確認

```bash
thinkpad-resident status 2>/dev/null | head -40
# 落ちていれば start（ユーザーが永続前提でも、落ちているときだけ）
thinkpad-resident start http-brain
```

素の `python -m http.server` は禁止（`thinkpad-resident` スキル準拠）。

### 3. MBA でブラウザを開く（best-effort）

```bash
ssh -o BatchMode=yes -o ConnectTimeout=5 mac "open $(printf %q "$URL")" || true
```

- 成功: チャットに URL を1行出す
- 失敗: 「MBA 到達不可。Thinkpad では `http://127.0.0.1:8766/...`」と URL だけ渡して続行

### 4. やらないこと

- セッション失敗として扱う
- IP をドキュメントに固定値で焼き付ける（例はよいが実行時は `tailscale ip -4`）
- PDF を無理に HTML 化してから開く（PDF は `sync_mac` 等の既存フロー）

## Mac mini 移行時

母艦が mini に移るときは、同スキルの「配信ホスト」を mini 上の tmux + `repo-http-serve` / `thinkpad-resident` 相当に読み替える。  
引き継ぎ: `research-brain/now/TODO.md` の Mac mini 節、および `wiki/compute-environments/mac-mini-migration-playbook.md` の HTTP 常駐項目。

## モデル

手順実行は現行エージェントで十分。下書きや説明文が要るときだけ `agy`（Flash）や `pi`（kimi-k3）を使う。
