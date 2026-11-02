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
| `--timeout <sec>` | 既定 900。Codex 超過時と dsh-sub 呼び出しの両方に渡す |

## Codex exec（成功経路）

モデル名は付けない。`preferred_auth_method` 等の削除済み `-c` は**付けない**（未知キーで exec 全体が失敗しうる）。

```sh
codex exec --json --cd "$repo" \
  --sandbox workspace-write \
  -c 'model_reasoning_effort="medium"' \
  --output-last-message "$tmpdir/last.txt" -
```

子プロセスの環境から **`OPENAI_API_KEY` / `CODEX_API_KEY` を除去**する（シェルにキーが残っていても ChatGPT ログインを優先）。

**Fast**: exec 引数では切らない。実行前に `~/.codex/config.toml` を読み、`service_tier = "fast"` または `[features] fast_mode = true` なら **exec せず dsh-sub**（理由を `reason` に書く）。契約後に `[features] fast_mode = false` 等を本人マシンで確認すること。

**使わない**: `--dangerously-bypass-approvals-and-sandbox` / `--approve-for-me` / `--full-auto` / 明示的モデル ID / Fast tier。

## フォールバック条件（→ `dsh-sub`）

1. `command -v codex` 失敗
2. `codex login status` が 0 以外
3. status が **`Logged in using ChatGPT` を含まない**、または **`Logged in using an API key`**
4. stderr または JSONL の**エラー種イベント**に `You've` / `You\u2019ve hit your usage limit` または `usage limit reached`（**モデル本文の stdout では判定しない**）
5. `~/.codex/config.toml` で Fast が有効
6. 本人が「今日は Codex を止める」と明示

`rate limit exceeded` **だけ**では落とさない。クレジット購入・API キーへの切替はしない。

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

`dsh-sub` の 5（契約違反）はラッパーを通してそのまま返る。

## プロンプト末尾（ラッパーが自動付与）

Codex 成功経路と **dsh-sub フォールバック**の両方で、返答に次を義務づける:
変更ファイル / 実行したテストと結果 / 確認したこと / やっていないこと / 残る不安。

## 禁止

- **OpenAI 従量 API**（子環境に API キーを残したまま exec）
- **Codex Fast**（config で有効なら exec 前にフォールバック）
- **Private タスクを Codex に出す**（Private は Composer 2.5）
- ネットワーク必須・ワークスペース外操作を Codex に期待する（workspace-write の範囲外）

## T3 Code ネイティブ委譲（`delegate_task`）との関係

- **T3 Code 環境（`delegate_task` 利用可能時）**: 司令塔（Opus 等）から `delegate_task`（`providerInstanceId: "codex"`, `model: "gpt-6.1-sol"`, `serviceTier: "default"`）で直接委譲する。UI での追跡・ワークツリー機能との統合を最優先とする。
- **非 T3 Code 環境（Claude Desktop Code モード / Cursor / 端末 CLI、本スキル）**: CLI ラッパー `codex-sub` を経由して `codex exec` を呼び出し、利用枠判定と `dsh-sub` 自動フォールバックを活用する。

## 正本

- 方針: `rules/models.md` §2.5
- 委譲: `rules/delegation.md` §5–§8
- 控え API: スキル `deepseek-harness`
