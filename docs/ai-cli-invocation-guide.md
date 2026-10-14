# AI CLI エージェント呼び出しガイド (OpenCode / Cursor / Antigravity)

本ドキュメントは、ローカル環境（mac / zsh）で利用可能な主要 AI CLI エージェント（**OpenCode**, **Cursor**, **Antigravity**）の Bash からの非対話・YOLO呼び出し方法および主要モデルの指定方法をまとめたものです。
全コマンドは実際にローカル環境で動作確認（最小トークン・思考オフ・即時終了テスト）を実施済みです。

---

## 1. ワンショット / YOLO 呼び出し 早見表

| ツール | コマンド形式 | YOLOフラグ | 実行例 |
| :--- | :--- | :--- | :--- |
| **OpenCode** | `opencode run [flags] "<prompt>"` | `--auto` | `opencode run --auto -m "deepseek/deepseek-flash#none" "Reply with OK" </dev/null` |
| **Cursor** | `cursor-agent -p --yolo [flags] "<prompt>"` | `--yolo` (`-f`) | `cursor-agent -p --output-format text --yolo --model composer-2.5 "Reply with OK" </dev/null` |
| **Antigravity** | `agy --dangerously-skip-permissions --print "<prompt>"` | `--dangerously-skip-permissions` | `agy --dangerously-skip-permissions --model gemini-3.8-flash-low --print "Reply with OK" </dev/null` |

---

## 2. OpenCode (`opencode`)

### 呼び出し仕様
- **CLI パス**: `/opt/homebrew/bin/opencode` (Version 2.0.26)
- **非対話実行**: `opencode run [flags] "<message>"`
- **自動承認 (YOLO)**: `--auto` （明示的に拒否されていない権限を自動承認）
- **モデル書式**: `--model, -m provider/model#variant`

> [!IMPORTANT]
> **非対話Bash呼び出し時の注意 (`</dev/null`)**  
> `opencode run` はバックグラウンドの常駐サービスと協調動作するため、標準入力（stdin）を開いたままにすると入力待ちでブロックする場合があります。  
> スクリプトやワンライナーから即時完了させるには、末尾に `</dev/null` をリダイレクトしてください。

### DeepSeek モデルと思考抑制 (`#none`)
OpenCode では DeepSeek の思考モード（Thinking）が `variant` として制御できます。  
`#none` を付与することで思考プロセス（Reasoning Token）を完全に無効化し、最小トークン・最速レスポンスでワンショット動作させることが可能です。

- **DeepSeek V4.1 Flash (思考オフ / 最小トークン)**
  ```bash
  opencode run --auto -m "deepseek/deepseek-flash#none" "Reply with only the word OK" </dev/null
  ```
- **DeepSeek V4 Pro (思考オフ / 最小トークン)**
  ```bash
  opencode run --auto -m "deepseek/deepseek-v4-pro#none" "Reply with only the word OK" </dev/null
  ```
- **思考有効化時の variant**:
  - `#low` (低推論)
  - `#high` (標準推論)
  - `#max` (最大推論)

### 主要モデル一覧
- **登録済み API モデル (DeepSeek)**:
  - `deepseek/deepseek-flash` (DeepSeek V4.1 Flash)
  - `deepseek/deepseek-v4-pro` (DeepSeek V4 Pro)
- **公式無料モデル (Zen / OpenAI互換)**:
  - `opencode/exo-free`
  - `opencode/ling-3.1-flash-free`
  - `opencode/space-bunny-free`
  - `opencode/step-5-preview-free`
  - `opencode/muse-spark-1.3-contributor-free`
- **設定・認証ファイル配置**:
  - 認証キー: `~/.local/share/opencode/auth.json`
  - モデル状態: `~/.local/state/opencode/model.json`
  - 設定ファイル: `~/.config/opencode/opencode.jsonc`

---

## 3. Cursor (`cursor-agent`)

### 呼び出し仕様
- **CLI パス**: `~/.local/bin/cursor-agent`
- **非対話実行**: `-p`, `--print`
- **出力形式**: `--output-format text` (または `json`, `stream-json`)
- **自動承認 (YOLO)**: `--yolo` (エイリアス: `-f`, `--force`)
- **モデル書式**: `--model <model-id>`
- **読み取り専用モード**: `--mode ask` または `--mode plan`

### ワンショット実行テスト
```bash
cursor-agent -p --output-format text --yolo --model composer-2.5 "Reply with only OK" </dev/null
```

### 主要モデル一覧
- **実装役 (自律実装・標準)**:
  - `composer-2.5` / `composer-2.5-fast` (dotfiles 規定の実装役モデル)
- **司令塔・設計・発想・敵対レビュー**:
  - `grok-4.7-high` / `cursor-grok-4.6-high` (司令塔役)
  - `claude-fable-5-1-thinking-high` (短時間発想・教員説明の穴・仮説1本のBRIEF向け最新モデル)
  - `claude-sonnet-5-thinking-high` (※要許可)
  - `gpt-5.6-terra-high` / `gpt-5.6-sol-high` (※レビュー分析時要許可)

---

## 4. Antigravity (`agy`)

### 呼び出し仕様
- **CLI パス**: `/opt/homebrew/bin/agy`
- **非対話実行**: `--print "<prompt>"` (または `-p="<prompt>"`)
- **自動承認 (YOLO)**: `--dangerously-skip-permissions`
- **モデル書式**: `--model <model-id>`
- **推論深度**: `--effort low|medium|high|xhigh|max`

> [!WARNING]
> **Go Flag Parser の罠 (`-p` の順序)**  
> `agy -p --dangerously-skip-permissions ...` と書くと、`-p` が後続の `--dangerously-skip-permissions` をプロンプト文字列として誤パースし、エラー（`code 2`）になります。  
> 必ず `--dangerously-skip-permissions` を前置し、`--print "メッセージ"` を使うか、`-p="メッセージ"` の形式で指定してください。

### 動作確認テスト
```bash
agy --dangerously-skip-permissions --model gemini-3.8-flash-low --print "Reply with only OK" </dev/null
```

### 主要モデル一覧 (`agy models` より抜粋)
- **日常使い・軽量・高速 (無許可で利用可)**:
  - `gemini-3.8-flash-high` / `gemini-3.8-flash-low`
  - `gemini-3.7-flash-high` / `gemini-3.7-flash-low`
  - `gemini-3.6-flash-high`
  - `gemini-3.1-pro-high`
  - `gpt-oss-120b-medium`
  - `claude-sonnet-5-5-high`
- **利用制限ポリシー (`GLOBAL_RULES.md`)**:
  - `claude-opus-5-5-*` は Google AI Pro の 5h クォータ制限が即時枯渇するため原則禁止。

---

## 5. まとめ: スクリプト用 テンプレートスニペット

```bash
#!/usr/bin/env bash
set -euo pipefail

# 1. OpenCode (DeepSeek Flash 思考オフ)
opencode run --auto -m "deepseek/deepseek-flash#none" "Hello" </dev/null

# 2. OpenCode (DeepSeek V4 Pro 思考オフ)
opencode run --auto -m "deepseek/deepseek-v4-pro#none" "Hello" </dev/null

# 3. Cursor (実装役 Composer 2.5)
cursor-agent -p --output-format text --yolo --model composer-2.5 "Hello" </dev/null

# 4. Antigravity (Gemini Flash)
agy --dangerously-skip-permissions --model gemini-3.8-flash-low --print "Hello" </dev/null
```
