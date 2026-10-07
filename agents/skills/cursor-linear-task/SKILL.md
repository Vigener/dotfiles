---
name: cursor-linear-task
description: >-
  Linear にタスク・チケット・Issue を追加・登録・起票する。
  Gemini (agy) など Linear MCP に直接アクセスできないエージェント環境から、ローカルの cursor-agent CLI を経由して Linear にタスクを登録し、now/TODO.md へ反映する。
  「Linearにタスク追加」「Linearのチケット作成」「Linearに起票」「Linear add task」「Linear issue」「add task in Linear」などで発動。
  ※注意: 数学・物理・機械学習等の文脈（線形代数・線形回帰・linear regression 等）における "linear" は対象外。
---

# cursor-linear-task

Gemini (agy) など Linear への直接アクセス権限（API / MCP）を持たない環境から、Cursor のローカル CLI (`cursor-agent`) を呼び出して Linear にタスク（Issue）を作成し、`now/TODO.md` にチケットリンクを反映する委譲パイプライン。

---

## 仕組みと前提

- **認証構造**: Cursor Desktop 側で認証済みの OAuth トークン（`mcp-auth.json`）を流用する。
- **設定ファイル**: `~/.cursor/mcp.json` に Linear MCP サーバーが定義されている必要がある（未設定の場合は下記を追記）。

```json
{
  "mcpServers": {
    "plugin-linear-linear": {
      "url": "https://mcp.linear.app/mcp"
    }
  }
}
```

---

## 基本実行コマンド

Gemini (agy) などの呼び出し元エージェントは、Bash コマンドを用いて非対話モードで `cursor-agent` を実行する。

```bash
cursor-agent -p --force --approve-mcps --trust --model auto "プロンプト..."
```

### オプション解説

| オプション | 意味・必要理由 |
|---|---|
| `-p` / `--print` | **非対話出力モード**。対話TUIを起動せず、結果を標準出力に出力する。スクリプトやエージェントからの呼び出しに必須。 |
| `-f` / `--force` | **ツール強制実行（自動承認）**。ファイル書き込みやシェル実行のたびに対話確認プロンプト（Y/n）を要求せず、自動承認する。ヘッドレス実行時の入力待ちハングを防止する。 |
| `--approve-mcps` | **MCPツール自動承認**。Linear MCP の各ツール呼び出しを自動で許可する。これがないとMCP実行確認待ちで停止する。 |
| `--trust` | **ワークスペース信頼**。現在の作業ディレクトリを信頼されたワークスペースとして扱い、セキュリティ警告プロンプトをスキップする。 |
| `--model auto` | **自動モデル選択（推奨）**。タスク起票のような定型処理を高コストなフロンティアモデルに過剰割り当てせず、最適な中軽量モデルへルーティングする。モデルナンバリングの陳腐化も防ぐ。 |

※ 特定の高推論モデル（例: `grok-4.7-high`）を明示したい場合は `--model grok-4.7-high` を指定することも可能。

---

## 標準ワークフロー

### 1. 前提設定の確認（初回または未設定時）

`~/.cursor/mcp.json` に `plugin-linear-linear` が存在するか確認する。

```bash
grep -q "plugin-linear-linear" ~/.cursor/mcp.json 2>/dev/null || cat << 'EOF' > ~/.cursor/mcp.json
{
  "mcpServers": {
    "plugin-linear-linear": {
      "url": "https://mcp.linear.app/mcp"
    }
  }
}
EOF
```

### 2. プロンプトの組み立て

プロンプトには以下の必須メタデータを明記する：

- **Team**: 既定は `LIFE`（タスクの対象に応じて適切なチームを指定）
- **Title**: タスクの概要
- **Priority**: 1 (Urgent), 2 (High), 3 (Medium), 4 (Low)
- **Due Date**: 期日（`YYYY-MM-DD` 形式）
- **Assignee**: `me`（本人）
- **Description**: 背景、参照ドキュメント、アクション項目、完了条件
- **事後処理の指示**: 発行された Issue ID（例: `LIFE-xx`）と URL を `now/TODO.md` の該当項目へ反映させる

### 3. 実行（ファイル経由またはヒアドキュメント）

長文プロンプトの場合は `inbox/prompt_cursor_grok_linear_xxx.txt` などに保存するか、コマンドラインに直接渡す。

```bash
cursor-agent -p --force --approve-mcps --trust --model auto "$(cat prompt.txt)"
```

### 4. 実行結果の検証

- `cursor-agent` の出力から Issue ID（`LIFE-xx`）と URL を確認する。
- `git diff now/TODO.md` を実行し、正本ファイルにチケットリンクが反映されたか確認する。

---

## 関連・参照

- `add-to-todo`: `now/TODO.md` への直接追記スキル（Linear を使わない場合）
- 設定正本: `~/.cursor/mcp.json`
- 認証トークン: `~/.cursor/projects/.../mcp-auth.json`
