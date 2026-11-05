---
name: cursor-linear-task
description: >-
  Linear にタスク・チケット・Issue を起票し、now/TODO.md へ反映する（書き込み専用）。
  参照（Read）は内蔵 Linear MCP を直接叩き本スキルは使わない。
  書き込みはユーザーの明示指示があるときだけ、1操作ずつ実行する。
  「Linearにタスク追加」「Linearのチケット作成」「Linearに起票」「Linear add task」「Linear issue作成」等で発動。
---

# cursor-linear-task

Linear へのタスク（Issue）起票と `now/TODO.md` への反映パイプライン。

## 規律と安全条件

- **参照 (Read)**: 「Linear のタスク確認」「期日確認」等の読み取りは本スキルを使わず、内蔵 Linear MCP ツールを直接呼び出して回答する。
- **書き込み (Write)**: `rules/delegation.md` §11 に従い、**ユーザーの明示指示があるときだけ・1操作ずつ**実行する。サービス操作や認証設定の無断変更は行わない。

## 1. 経路判定

実行環境に応じて起票経路を判定する。

| 実行環境 | 起票経路 | 備考 |
| --- | --- | --- |
| **OpenCode / Claude** | **Linear MCP を直接使用** | 接続済み MCP で起票し、ID / URL を取得 |
| **agy / Cursor 等** | **`cursor-agent` CLI への委譲** | 非対話 CLI 経由で起票し、TODO へ反映 |

## 2. 設定確認（既存設定を保持）

`cursor-agent` 経由で実行する場合、`~/.cursor/mcp.json` に Linear MCP が定義されているか確認する。

```bash
# 設定の存在確認
jq '.mcpServers["plugin-linear-linear"]' ~/.cursor/mcp.json 2>/dev/null
```

未設定なら、必要なサーバー定義は次のとおり。設定追加が許可されている場合のみ、
既存 JSON を正常に解析できることを確認し、他の項目を保持して `mcpServers` に追加する。
ファイルの読み取り・解析に失敗した場合は停止し、空の設定で上書きしない。

```json
"plugin-linear-linear": { "url": "https://mcp.linear.app/mcp" }
```

## 3. 起票プロンプトと実行

### プロンプト指定項目

- **Team**: 既定 `LIFE`（対象リポジトリ・内容に応じた適切なチーム）
- **Title**: タスク名
- **Priority**: 1 (Urgent), 2 (High), 3 (Medium), 4 (Low)
- **Due Date**: 期日（`YYYY-MM-DD`）
- **Assignee**: `me`（本人）
- **Description**: 背景、参照ドキュメント、完了条件
- **事後指示**: 発行された Issue ID（例: `LIFE-xx`）と URL を `now/TODO.md` へ反映させる

### コマンド実行

CLI 委譲時の既定は `--model auto`。Linear 起票では従来どおり自動モデル選択を使う。
ユーザーがモデルを明示指定した場合は、その指定と `model-route` の手順に従う。
MCP 直接起票では CLI のモデル選択は不要。

```bash
cursor-agent -p --force --approve-mcps --trust --model auto "起票内容と TODO 反映の指示"
```

| オプション | 役割 |
| --- | --- |
| `-p` / `--print` | 非対話出力モード（標準出力に出力） |
| `-f` / `--force` | ツール自動承認（入力待ちハングを防止） |
| `--approve-mcps` | MCP ツールの実行自動承認 |
| `--trust` | ワークスペース警告のスキップ |

## 4. Issue ID / URL の確認と TODO 反映

1. 選択した経路の応答から Issue ID（例: `LIFE-xx`）と URL を取得・確認する。
2. `now/TODO.md` の該当箇所にチケットリンクを反映する。
3. `git diff now/TODO.md` で反映結果を確認する。

## 関連

- `add-to-todo`: Linear を使わず `now/TODO.md` へ直接追記するスキル
- モデル選定正本: `rules/models.md` / `model-route`
- 設定ファイル: `~/.cursor/mcp.json`
