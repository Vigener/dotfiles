---
name: deepseek-harness
description: "DeepSeek Harness (dsh) を CLI サブエージェントとして呼び出すための実装契約。dsh-sub の引数・出力JSON・exit code、effort 方針、権限、テレメトリ、トラブルシュートを扱う。「DeepSeekでサブエージェント」「dsh-sub で」「V4.1 Flash に投げて」「dsh の使い方」で発動。"
---

# deepseek-harness (`dsh-sub`)

**W1 の控え。** `codex-sub` が無い・未ログイン・利用上限のときに呼ばれる（ラッパーが自動実行）。
明示 `dsh-sub` 指定時もこの契約。主力 W1 は Codex（スキル `codex-harness`）。

オーケストレータから DeepSeek Harness を**ワンショットのサブエージェント**として呼ぶための契約。
対話 UI は前提にしない。1タスク1プロセスで完結させる。

## 前提

- **実体**: `~/.local/share/mise/installs/node/lts/bin/dsh`（`@deepseek-ai/dsh@0.2.1-rc.2`）
- **認証**: `~/.dsh/.env` の `DEEPSEEK_API_KEY`（パーミッション `600`。環境変数 → `./.env` → `~/.dsh/.env` の順で解決）
- **プロファイル**: `~/.dsh/profiles/headless/`

## モデルと effort（CLI 受理値と既定）

用途別割当や利用条件は `../../rules/models.md` §2.5 および `../../docs/routing.md` を正本とする。

| パラメータ | CLI 受理値 | 既定 / 扱い |
|---|---|---|
| `--model` | モデル ID（用途別選択は正本参照） | overlay 未生成時はプロファイル継承。生成時の省略値は `deepseek-flash` |
| `--effort` | `off`, `low`, `high`, `max` | overlay 未生成時はプロファイル継承。生成時の省略値は `high` |
| `--provider` | プロバイダ ID | overlay の既定は `deepseek-official`。単独指定では overlay を生成しない |

- `--model` または `--effort` を指定した場合に overlay を生成する。利用するモデル・effort の判断は正本に従う。

## 呼び出し

```sh
dsh-sub --repo /path/to/repo --prompt "タスク本文"
```

| オプション | 意味 |
|---|---|
| `--repo <dir>` | 必須。子プロセスの cwd＝ワークスペース根 |
| `--prompt <text\|->` | タスク本文。`-` で stdin から読む（長文・引用はこちら） |
| `--session <id>` | 既存セッションを再開。未知IDは実行前エラー |
| `--model <id>` | `deepseek-flash` / `deepseek-v4-pro` |
| `--provider <id>` | プロバイダ指定。省略時 `deepseek-official` |
| `--effort <level>` | `off` / `low` / `high` / `max`（`--model`/`--effort` 指定時のみ overlay 生成、省略時 `high`） |
| `--timeout <sec>` | 既定 900。超過時はプロセスグループごと kill |
| `--danger` | `DSH_PERMISSION_MODE=danger-full-access`（原則使わない） |
| `--no-telemetry` | OTel と DeepSeek セッションログ同梱をその回だけ無効化 |
| `--keep-raw <path>` | 生の NDJSON を保存（デバッグ用） |

例:

```sh
# 実装タスク（既定 high）
dsh-sub --repo ~/ghq/github.com/Vigener/dotfiles --prompt "bin/dsh-sub のテストを追加して"

# 難所だけ max
dsh-sub --repo ~/repo --prompt "この設計の破綻点を列挙して" --effort max

# 長文は stdin
{ echo "次の差分をレビューして:"; git diff; } | dsh-sub --repo . --prompt -

# 継続
dsh-sub --repo . --session session-xxxx --prompt "続き: 失敗したテストを直して"
```

## 出力契約

stdout は**常に1行の JSON**。診断は stderr。

```json
{"ok":true,"sessionId":"session-...","cwd":"/path","text":"最終回答",
 "usage":{"input":2482,"output":5,"cacheRead":5376,"cacheWrite":0,"total":7863},
 "tools":{"calls":1,"denied":0},"ms":2115}
```

失敗時は `ok:false` + `code` / `message` / `retryable` / `exitCode`。

| exit | 意味 |
|---|---|
| 0 | 成功（`ok:true` かつ `text` 非空） |
| 2 | 引数エラー |
| 3 | 実行失敗（API・認証・設定） |
| 4 | タイムアウト |
| 5 | 契約違反（exit 0 なのに final が空） |

`retryable:true` は `RATE_LIMIT` / `TIMEOUT` / `TRANSPORT` / `SERVER` / `EMPTY_RESPONSE` のみ。
**`ok` だけ見ればよい**。`sessionId` を保存しておけば同じ会話を再開できる。

オーケストレータ側の分岐:

```sh
out=$(dsh-sub --repo "$repo" --prompt "$task") || true
ok=$(printf '%s' "$out" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>console.log(JSON.parse(s).ok))')
```

## 権限と承認

- 既定は `workspace-write` + 承認 `ask`。**headless には承認応答者がいないため fail-closed**（危険操作は拒否）
- ワークスペース内の読み書き・テスト実行は通る
- ワークスペース外への書き込みや破壊的操作が必要な場合だけ `--danger`。オーケストレータが無制限に使うのは禁止
- 拒否は `tools.denied` に計上される

## テレメトリ

| 系統 | 既定 | `--no-telemetry` |
|---|---|---|
| `session-telemetry-otel` | `FEEDBACK_ONLY`（フィードバック時のみ送信） | 無効化 |
| `session-log-deepseek` | **ON**（次回リクエストにセッションログ差分を同梱） | 無効化 |

モデル入力・応答品質は変わらない。機密リポジトリでは `--no-telemetry` を付ける（Private の扱い・担当モデルは `../../rules/models.md` §2.1 参照）。

## トラブルシュート

| 症状 | 対処 |
|---|---|
| `MISSING_CREDENTIAL` | `~/.dsh/.env` のキーを確認。空の環境変数は `.env` を隠す |
| `DSH_NOT_FOUND` | PATH に `dsh` が無い。`npm i -g` 後にシェル再起動 |
| 設定が反映されない | `dsh --profile headless --dump-config` で合成結果を確認 |
| 起動が遅い/失敗 | `~/.dsh/logs/` の `startup-*.log` を読む |
| バージョン不一致 | `dsh --version` とプラグインの `engines.dsh` を確認 |

## やらないこと

- 対話 UI（`dsh web`）をオーケストレーションに使わない
- `effort: max` を常用しない
- `dsh plugin` を npm 版で使おうとしない（npm 配布版はプラグイン管理を拒否）
- `latest` タグで更新しない（developer preview。バージョン固定）
