---
name: open-artifact
description: >-
  人間レビュー向け HTML を http-brain 等経由で MBA ブラウザに開く。
  Plan 締め・/goal 完了・「開いて」で発動。流れは [HTML保存 → URL決定 → ssh mac open]。
  open 失敗時も URL は必ずチャットに出す。素の python -m http.server は使わない。
---

# open-artifact

## 標準フロー（Plan /goal の締めでも同じ）

```text
1. 人間向け成果を HTML として保存
   （トーン選択: スキル human-review-html → wiki/templates/human-review/ をコピー）
   ※ 研究用記号・非一般用語は sticky サイドバー／スマホドロワー必須
     （human-review-html「用語サイドバー」節）。本文だけで記号暗記を要求しない。
2. Tailscale IP で URL を組み立てる
3a. 今すぐ開く: ssh mac "open 'URL'"
3b. セッション末に開く: URL を ~/.cursor/open-on-stop.url に書いて stop hook に任せる
```

3a と 3b はどちらか1つだけ実行する。ユーザー指定がなければ 3a。
ntfy はユーザーが通知を求めたときだけ送る。3a/3b に常時併送しない。

Cursor `stop` hook（`on-stop-open-artifact.sh`）は **3b のマーカーがあるときだけ**発火する。スキルとフックはセット。

テンプレ案内: `http://<TS_IP>:8766/wiki/templates/human-review/INDEX.html`

## 前提

- Thinkpad: `http-brain`（`:8766` → `~/brain/research-brain`）tmux 常駐
- 人間レビュー=HTML / エージェント間=Markdown
- best-effort の範囲は 3a/3b の open コマンドだけ。手順1の HTML 保存と URL のチャット出力は省略しない
- MBA オフラインで open が失敗しても、エラーは無視して URL をチャットに出す

## スマホ通知（ntfy）と Click URL

ユーザーが「ntfy」「通知」と言ったときだけ `~/bin/ntfy-notify "題" "本文" "$URL"` を送る。言っていなければ送らない。

**必須ルール: Click / スマホで開く URL は必ず `.html`。**  
`.md` を http-brain で直開きすると `text/markdown`（charset なし）になり、Android で文字化け・極小表示になる。  
`ntfy-notify` は `.md` の Click を拒否する。詳細: `wiki/ai-engineering/ntfy-phone-notify.md`

## 手順

### 1. パス → URL

| ローカルパス | サイト | URL |
|---|---|---|
| `~/brain/research-brain/wiki/...` | http-brain :8766 | `http://<TS_IP>:8766/wiki/...` |
| sandbox 配下 | http-sandbox :8765 | `http://<TS_IP>:8765/<sandbox からの相対パス>` |
| 上記以外 | `thinkpad-resident status` で確認 | status 出力にないポートは使わない |

```bash
TS_IP="$(tailscale ip -4 | head -n1)"
REL="wiki/ai-engineering/example.html"   # research-brain からの相対
URL="http://${TS_IP}:8766/${REL}"
```

### 2. 配信サイトの起動

HTML の置き場が research-brain なら `http-brain`、sandbox なら `http-sandbox`。
`status` にその名前が running でなければ start する。

```bash
thinkpad-resident status 2>/dev/null | head -40
thinkpad-resident start http-brain   # research-brain の HTML のとき
```

### 3a. 今すぐ開く（推奨・締め）

```bash
ssh -o BatchMode=yes -o ConnectTimeout=5 mac "open '$URL'" || true
echo "$URL"
```

### 3b. セッション末に開く（opt-in）

```bash
printf '%s\n' "$URL" > ~/.cursor/open-on-stop.url
# stop hook が1回 open してマーカーを消す
```

### 4. やらないこと

- セッション失敗扱い / IP のドキュメント焼き付け / 素の `python -m http.server`
- stop hook に重い agy/pi レビューを載せない（`adversarial-review` スキルを明示呼び出し）
- **スマホ／ntfy の Click に `.md` を渡す**（必ず HTML 成果物の URL）

## 関連スキル

| スキル | 関係 |
|---|---|
| `human-review-html` | トーン別テンプレ選択・複製（`wiki/templates/human-review/`） |
| `goal` | Goal 固定 → 作業 → **締めは本スキルで HTML open** |
| `update-agent-config` | 挙動設定変更時の層判定 |
| `adversarial-review` | HTML 化する前の品質ゲート（任意） |

## Mac mini 移行（未実施）

配信ホストは Thinkpad のみ。ユーザーが「mini」と明示するまでホスト・ポートを読み替えない。移行手順は playbook R13/R14。
