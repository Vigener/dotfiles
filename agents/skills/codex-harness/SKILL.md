---
name: codex-harness
description: "Codex CLI を CLI サブエージェントとして呼び出す契約。codex-sub の引数・Codex exec フラグ・ChatGPT 認証・dsh-sub フォールバック・返却 JSON・exit code、W1 向け禁止事項を扱う。「Codexで実装」「codex-sub で」「W1 Codex」で発動。"
---

# codex-harness (`codex-sub`)

オーケストレータから **Codex CLI（ChatGPT Plus ログイン）** を W1 ワンショットサブエージェントとして呼ぶ契約。
`codex` が無い・未ログイン・API キー認証・利用上限のときは **同じ引数で `dsh-sub` にフォールバック**する（散文のフォールバック指示は読み飛ばされるためラッパーが実行する）。

## 呼び出し

```sh
codex-sub --repo /path/to/repo --prompt "タスク本文"
codex-sub --repo . --prompt -
```

| オプション | 意味 |
| --- | --- |
| `--repo <dir>` | 必須。`codex exec --cd` / 子 cwd |
| `--prompt <text\|->` | タスク本文。`-` で stdin |
| `--timeout <sec>` | 既定 900。超過時は dsh-sub へフォールバック |

## Codex exec（成功経路）

モデル名は付けない。次のフラグのみ。

```sh
codex exec --json --cd "$repo" \
  --sandbox workspace-write --ask-for-approval never \
  -c 'preferred_auth_method="chatgpt"' \
  -c 'model_reasoning_effort="medium"' \
  --output-last-message "$tmpdir/last.txt" -
```

**使わない**: `--dangerously-bypass-approvals-and-sandbox` / `--approve-for-me` / `--full-auto` / Fast / 明示的モデル ID。

## フォールバック条件（→ `dsh-sub`）

1. `command -v codex` 失敗
2. `codex login status` が 0 以外
3. **ChatGPT 認証でない** — 保守的判定: 環境に `OPENAI_API_KEY` がある、
   または status 出力が API キー従量を示す（**文言は契約後に本人マシンで
   `codex login status` を確認**）
4. stderr / JSONL に `You've hit your usage limit` または
   `usage limit reached`（その回は Codex 成果を採用せず dsh-sub へ）
5. 本人が「今日は Codex を止める」と明示

`rate limit exceeded` **だけ**では落とさない。クレジット購入・`OPENAI_API_KEY` への切替はしない。

## 出力契約

stdout は**常に1行 JSON**。診断は stderr。

成功（Codex）:

```json
{"ok":true,"provider":"codex","text":"…","session":"thread-…"}
```

フォールバック（dsh-sub）:

```json
{"ok":true,"provider":"dsh-sub","fallback":"dsh-sub",
 "reason":"codex binary not found","text":"…","sessionId":"…"}
```

`dsh-sub` 本体のフィールド（`usage` 等）はフォールバック時もそのまま残る。

## exit code

| code | 意味 |
| --- | --- |
| 0 | 成功 |
| 2 | 引数・usage |
| 3 | 実行失敗 |
| 4 | タイムアウト |

`dsh-sub` と同じ。

## プロンプト末尾（ラッパーが自動付与）

返答に次を義務づける: 変更ファイル / 実行したテストと結果 /
確認したこと / やっていないこと / 残る不安。

## 禁止

- **OpenAI 従量 API**（`OPENAI_API_KEY` 経由の Codex）
- **Codex Fast**（サブスク枠 2.5 倍消費）
- **Private タスクを Codex に出す**（Private は Composer 2.5）
- ネットワーク必須・ワークスペース外操作を Codex に期待する（`--ask-for-approval never` + workspace-write の範囲外）

## 正本

- 方針: `rules/models.md` §2.5
- 委譲: `rules/delegation.md` §5–§8
- 控え API: スキル `deepseek-harness`
