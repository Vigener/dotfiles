---
name: cursor-linear-task
description: >-
  Linear にタスク・チケット・Issue を【追加・登録・起票】する（書き込み専用）。
  agy (Gemini等) からローカルの cursor-agent CLI を経由して Linear にタスクを登録し、now/TODO.md へ反映する。
  【重要・ハイブリッド規律】
  - 追加・起票（Write）: 本スキルを発動し、cursor-agent (--model auto) に隔離委譲する。
  - 参照・確認（Read）: 「Linearのタスク確認」「未完了一覧」「期日確認」等の読み取りは本スキルを使わず、agy 内蔵の Linear MCP を直接叩いて即時回答する。
  「Linearにタスク追加」「Linearのチケット作成」「Linearに起票」「Linear add task」「Linear issue作成」「add task in Linear」などで発動。
  ※注意: 数学・物理・機械学習等の文脈（線形代数・線形回帰・linear regression 等）における "linear" は対象外。
---

# cursor-linear-task

Linear へのタスク（Issue）作成と `now/TODO.md` へのリンク反映を、Cursor のローカル CLI (`cursor-agent --model auto`) に丸投げ委譲するパイプライン。

---

## 運用方針（ハイブリッド構成: Read agy / Write Cursor）

agy（Gemini / Claude）と Cursor の長所を組み合わせ、安定性とコンテキスト効率を両立したハイブリッド運用をとる。

| 操作種別 | 担当エージェント | 実行手段 | 理由・メリット |
|---|---|---|---|
| **参照 (Read)**<br>一覧・ステータス・期日確認 | **agy (直接)** | 内蔵 Linear MCP<br>(`list_issues`, `get_issue` 等) | **最速（0.5秒で即答）**。別プロセスを起動するオーバーヘッドをゼロにし、会話のリズムを崩さない。 |
| **起票 (Write)**<br>新規追加・チケット作成 | **Cursor (委譲)**<br>※本スキル | `cursor-agent`<br>(`--model auto`) | **コンテキスト隔離 ＆ 安定性**。<br>1. agy の MCP は公式提供ではなく書き込み時の挙動が不安定になるリスクをヘッジ。<br>2. 「起票 → ID/URL取得 → `now/TODO.md` 更新」の泥臭い往復を別プロセスへ隔離し、メインチャットのトークンを汚さない。<br>3. Cursor Pro の余剰枠（Auto モデル）を有効活用する。 |

> [!NOTE]
> ユーザーから「Linearのタスク一覧見せて」「LIFE-12 の期日っていつだっけ？」などの **参照（Read）** を求められた場合は、本スキルを起動せず agy 自身の内蔵 MCP ツールで直接回答すること。

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

agy などの呼び出し元エージェントは、Bash コマンドを用いて非対話モードで `cursor-agent` を実行する。

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

## 標準ワークフロー（起票時）

### 1. 前提設定の確認（初回または未設定時）

`~/.cursor/mcp.json` に `plugin-linear-linear` が存在するか確認する。

```bash
grep -q "plugin-linear-linear" ~/.cursor/mcp.json 2>/dev/null || cat << "JSON_EOF" > ~/.cursor/mcp.json
{
  "mcpServers": {
    "plugin-linear-linear": {
      "url": "https://mcp.linear.app/mcp"
    }
  }
}
JSON_EOF
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
- agy 内蔵 MCP 設定: `~/.gemini/config/mcp_config.json`（Read 用）
