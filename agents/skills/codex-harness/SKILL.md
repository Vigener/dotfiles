---
name: codex-harness
description: >-
  Codex CLI を CLI サブエージェントとして呼び出す契約。codex-sub の引数・
  Codex exec フラグ・ChatGPT 認証・停止条件・返却 JSON・exit code、
  W1 向け禁止事項を扱う。「Codexで実装」「codex-sub で」「W1 Codex」で発動。
---

# codex-harness (`codex-sub`)

オーケストレータから **Codex CLI（ChatGPT Plus ログイン）** を
W1 ワンショットサブエージェントとして呼ぶ契約。
`codex` が無い・未ログイン・API キー認証・利用上限・タイムアウトなら
失敗JSONを返して停止する。**API・dsh-subへ自動切替しない。**

## API との分離

DeepSeek が必要・許可済みの場合は `dsh-sub` を直接呼ぶ。
許可の所在は `../../rules/models.md` §2.5。

## 呼び出し

```sh
codex-sub --repo /path/to/repo --prompt "タスク本文"
codex-sub --repo . --prompt -
```

| オプション | 意味 |
| --- | --- |
| `--repo <dir>` | 必須。`codex exec --cd` / 子 cwd |
| `--prompt <text\|->` | タスク本文。`-` で stdin |
| `--timeout <sec>` | 既定 900。超過時はプロセスグループを停止し exit 4 |

## Codex exec（成功経路）

モデル名は付けない。`preferred_auth_method` 等の削除済み `-c` は**付けない**
（未知キーで exec 全体が失敗しうる）。

```sh
codex exec --json --cd "$repo" \
  --sandbox workspace-write \
  -c 'model_reasoning_effort="medium"' \
  --output-last-message "$tmpdir/last.txt" -
```

子プロセスの環境から **`OPENAI_API_KEY` / `CODEX_API_KEY` を除去**する
（シェルにキーが残っていても ChatGPT ログインを優先）。

**Fast**: exec 引数では切らない。実行前に `~/.codex/config.toml` を読み、
`service_tier = "fast"` または `[features] fast_mode = true` なら
**execせず停止**（理由を `message` に書く）。
契約後に `[features] fast_mode = false` 等を本人マシンで確認すること。

**使わない**:
`--dangerously-bypass-approvals-and-sandbox` / `--approve-for-me` /
`--full-auto` / 明示的モデル ID / Fast tier。

## 停止条件

1. `command -v codex` 失敗
2. `codex login status` が 0 以外
3. status が **`Logged in using ChatGPT` を含まない**、または
   **`Logged in using an API key`**
4. stderr または JSONL の**エラー種イベント**に
   `You've` / `You\u2019ve hit your usage limit` または
   `usage limit reached`（**モデル本文の stdout では判定しない**）
5. `~/.codex/config.toml` で Fast が有効
6. 本人が「今日は Codex を止める」と明示

`rate limit exceeded` **だけ**を利用上限とは判定しない
（exec失敗は通常の失敗として返す）。クレジット購入・API キーへの切替はしない。

## 出力契約

stdout は**常に1行 JSON**。診断は stderr。

成功（Codex）:

```json
{"ok":true,"provider":"codex","text":"…","session":"thread-…"}
```

停止:

```json
{"ok":false,"provider":"codex","code":"UNAVAILABLE","message":"not found"}
```

起動前の不備は `UNAVAILABLE`、利用上限は `USAGE_LIMIT`、超過は `TIMEOUT`、
通常の実行失敗・空応答は `RUN_FAILED`。
引数不備は `provider: codex-sub` / `USAGE`。

## exit code

| code | 意味 |
| --- | --- |
| 0 | 成功 |
| 2 | 引数・usage |
| 3 | 実行失敗 |
| 4 | タイムアウト |

APIラッパーのexit codeは伝播しない。

## プロンプト末尾（ラッパーが自動付与）

Codexへのプロンプトには、返答に次を義務づける:
変更ファイル / 実行したテストと結果 / 確認したこと / やっていないこと / 残る不安。

## 禁止

- **OpenAI 従量 API**（子環境に API キーを残したまま exec）
- **Codex Fast**（config で有効なら exec 前に停止）
- **Private タスクを Codex に出す**
  （Private の扱い・担当モデルは `../../rules/models.md` §2.1 参照）
- ネットワーク必須・ワークスペース外操作を Codex に期待する
  （workspace-write の範囲外）

## T3 Code ネイティブ委譲（`delegate_task`）との関係

- **T3 Code 環境**: ネイティブ委譲のモデル・設定・許可は
  `rules/models.md` §2.5 に従う。本スキルの CLI 契約とは区別する。
- **非 T3 Code 環境（Claude Desktop Code モード / Cursor / 端末 CLI）**:
  CLI ラッパー `codex-sub` を経由して `codex exec` を呼び出し、
  利用枠判定を行い、使えなければ停止する。

## 正本

- 方針: `rules/models.md` §2.5
- 委譲: `rules/delegation.md` §5–§8
- 控え API: スキル `deepseek-harness`
