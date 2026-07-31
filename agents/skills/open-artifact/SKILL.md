---
name: open-artifact
description: >-
  人間レビュー向け HTML を http-brain 等経由で MBA ブラウザに開く。
  Plan 締め・/goal 完了・「開いて」で発動。流れは [HTML保存 → URL決定 → ssh mac open]。
  失敗は best-effort。素の python -m http.server は使わない。
---

# open-artifact

## 標準フロー（Plan /goal の締めでも同じ）

```text
1. 人間向け成果を HTML として保存
   （トーン選択: スキル human-review-html → wiki/templates/human-review/ をコピー）
2. Tailscale IP で URL を組み立てる
3a. 今すぐ開く: ssh mac "open 'URL'"
3b. セッション末に開く: URL を ~/.cursor/open-on-stop.url に書いて stop hook に任せる
```

Cursor `stop` hook（`on-stop-open-artifact.sh`）は **3b のマーカーがあるときだけ**発火する。スキルとフックはセット。

テンプレ案内: `http://<TS_IP>:8766/wiki/templates/human-review/INDEX.html`

## 前提

- Thinkpad: `http-brain`（`:8766` → `~/brain/research-brain`）tmux 常駐
- 人間レビュー=HTML / エージェント間=Markdown
- MBA オフライン時の失敗は無視して URL をチャットに出す

## 手順

### 1. パス → URL

| ローカルパス | サイト | URL |
|---|---|---|
| `~/brain/research-brain/wiki/...` | http-brain :8766 | `http://<TS_IP>:8766/wiki/...` |
| sandbox 等 | http-sandbox 等 | `thinkpad-resident` に従う |

```bash
TS_IP="$(tailscale ip -4 | head -n1)"
REL="wiki/ai-engineering/example.html"   # research-brain からの相対
URL="http://${TS_IP}:8766/${REL}"
```

### 2. http-brain 生存確認（任意）

```bash
thinkpad-resident status 2>/dev/null | head -40
thinkpad-resident start http-brain   # 落ちているときだけ
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

## 関連スキル

| スキル | 関係 |
|---|---|
| `human-review-html` | トーン別テンプレ選択・複製（`wiki/templates/human-review/`） |
| `goal` | Goal 固定 → 作業 → **締めは本スキルで HTML open** |
| `update-agent-config` | 挙動設定変更時の層判定 |
| `adversarial-review` | HTML 化する前の品質ゲート（任意） |

## Mac mini 移行

配信ホストを mini の tmux + resident 相当に読み替え。playbook R13/R14。
