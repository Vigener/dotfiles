# agents ルール再編 作業計画（2026-10-21）

> 作業ログ。正本ではない。コンパクション後に「決定事項・現在地・次の作業」を復元するためのメモ。
> 数値は点時点の参考値であり SSOT ではない。

## 0. 目的

`agents/GLOBAL_RULES.md` の陳腐化を解消し、「常時注入する Tier 0」と「必要時に読む Tier 1」に分離する。
環境依存の数値・モデル slug・ハーネス固有記述を、不変の規律から切り離す。

## 1. 確定事項（変更しない）

- **段階的開示**: Tier 0（常時）＋ `rules/*.md`（必要時）＋ `docs/`（詳細）＋ スキル。
- **モデル方針の SSOT は dotfiles**。research-brain 側は参照先であり正本ではない。
- **Claude は Team シート優先**。API は最後の手段で、API を使うなら安価な DeepSeek 等を優先。
- **数値（%・$・残量）はファイルに書かない**。`~/dotfiles/bin/update-ai-usage` で都度取得する。
- **リンク**: `file:///` とホスト絶対パス禁止。相対パスまたは `[[WikiLink]]`。
- **セクション番号参照（`§`）は廃止**。RULE 名かファイルパスで参照する。
- **T3 と Antigravity は物理分離**（`rules/delegation.md` 内では `## T3` / `## Antigravity` に分ける）。
- **herdr / pi は主経路から外す**。T3 `delegate_task` と `agy` / `cursor-agent` に集約。
- **inherit 委譲**: `delegate_task` に `{ providerInstanceId: "opencode", model: "opencode/deepseek-v4.1-flash-free" }`、options は空。実測済み。

## 2. 完了済み

### Phase 0: 注入経路の確定と配線（commit b152016）

実測結果:

| ハーネス | 自動で読む場所 | 結果 |
|---|---|---|
| OpenCode | プロジェクト `AGENTS.md` / `~/.config/opencode/AGENTS.md` | 有効 |
| OpenCode | `opencode.json` の `instructions` | **無効**（v2 のこのビルドでは機能しない） |
| Claude Code | `~/.claude/CLAUDE.md` | 有効 |
| agy | プロジェクト `AGENTS.md` / `GEMINI.md`、`~/.gemini/AGENTS.md` | 有効 |
| agy | プロジェクト `CLAUDE.md` | 無効 |

配線（symlink 3本、`bin/link-dotfiles-macos.sh` に追記済み）:

```
~/.config/opencode/AGENTS.md ─┐
~/.claude/CLAUDE.md          ├─→ ~/dotfiles/agents/GLOBAL_RULES.md
~/.gemini/AGENTS.md          ─┘
```

### Phase 1: Tier 0 化と rules/ 分割（commit 860d8b4）

- `GLOBAL_RULES.md`: 153行 → 48行
- 新規: `rules/models.md` `rules/hpc.md` `rules/delegation.md` `rules/artifacts.md` `rules/links.md` `rules/paper.md`
- `rules/cursorrules`: 逐語コピーを削除し、Cursor 差分＋Tier 0 要約に
- `skills/adversarial-review/SKILL.md`: `RULE[...]` 参照を `rules/delegation.md` に差し替え
- 検証: `§` 0件、`RULE[` 0件、参照切れ 0件、3ハーネスへの注入確認済み

## 3. クォータ参考値（2026-10-21 14:35 時点）

| 枠 | 残量 | リセット |
|---|---|---|
| Argon（agy 独立枠） | 34.0% | 2d21h |
| Gemini（agy） | 0.2% | 2d21h |
| agy Claude/GPT | 0.0% | 3d22h |
| Claude Team | 5h 100% / 7d 100% | 6d3h |
| Cursor | 1.9% | 明日 16:24 |
| DeepSeek | $1.22 | — |

再取得:
`~/dotfiles/bin/update-ai-usage --format markdown --no-notify --no-write-runcat`

## 4. Phase 2（完了）: rules/ の精錬と SSOT 一本化

**目的**: 同じルールが複数箇所に書かれている状態を解消し、各ルールの正本を1つにする。

### 作業対象

1. **`rules/models.md`**
   - 冒頭の「正本: research-brain/...」を「正本: 本ファイル（dotfiles）」に変更。
   - 詳細な役割表は `docs/routing.md`（Phase 2 で前倒し作成済み）へ置き、ここは方針と参照だけにする。
   - `models.md` 内に残る数値・slug の最終確認。
2. **`skills/model-route/SKILL.md`**
   - 役割表・%・slug の表を削除。
   - `rules/models.md` と `docs/routing.md` を読んで判定する薄いラッパーにする。
   - `description`（トリガー文）は維持する。
3. **`rules/delegation.md`**
   - `call_mcp_tool` / `ServerName` など、現行ハーネスに合わない記述を削除。
   - inherit の実測形（`opencode/deepseek-v4.1-flash-free`、options 空）を反映。
   - T3 → Antigravity → CLI の順序と使い分けを明確化。
4. **`rules/cursorrules`**
   - Tier 0 要約の重複範囲を確認。Cursor は `rules/*.md` を自動で読まないため、要約は必要。
   - 役割表は `rules/models.md` への参照に寄せる。
5. **`glossary.md`**
   - `TB` を「未使用・保険」に更新。
6. **重複監査**
   - 各ルールの正本が1箇所だけか確認（Cursor 要約は例外）。
   - `git grep` で旧参照（`RULE[`、`§`、`6.4%`、`herdr 優先`、`pi`）を確認。

### 完了条件

- `model-route` に数値・slug の表がない。
- `rules/models.md` の正本が dotfiles になっている。
- 同一ルールの二重記述がない（Cursor 要約を除く）。
- `§` / `RULE[` / 死パスが 0。
- 変更が 4〜6 ファイル程度に収まっている。

### 結果（2026-10-21 完了）

- 新規 `docs/routing.md`（役割表・環境表・昇格/降格・ペース配分）
- `model-route` は 165行 → 約40行。数値・slug 表を削除
- `models.md` の正本を dotfiles に変更し、Claude の認証順序を明確化
- `cursorrules` の役割表を参照1本に
- 旧 `user_model_routing_mental_model.md` に「経緯記録」バナーを追加

### やらないこと

- `docs/user_model_routing_mental_model.md` の4分割（Phase 3）。
- スキルの削除・改名（Phase 4）。
- `cursorrules` のチャット出力フォーマット変更。

## 5. Phase 3 以降（概略）

### Phase 3: docs 整理と数値撤去

- `docs/user_model_routing_mental_model.md`（41KB）を `docs/lessons.md` / `docs/history/` に分割（役割表は Phase 2 で `docs/routing.md` へ移設済み）。
- `quota_snapshot.md` は**作らない**（数値を保存しない方針のため）。
- 数値は `update-ai-usage` の参照に置換。

**2026-10-21 進捗**: Phase 3 完了。規範性の明示・陳腐化した表の削除・数値撤去は圧縮時に済ませ、
内容を `docs/lessons.md`（事故3件＋残量の読み方）と `docs/history/2026-model-decisions.md`（契約経緯・撤回した選択肢）に分割した。
旧パス `docs/user_model_routing_mental_model.md` は転送先を書いたポインタだけ残す（他マシンの旧ルール対策）。
併せて Sonnet は agy、Opus は Claude Team という分担を確定した（`rules/models.md` §3、`docs/routing.md` §4）。

### Phase 4: スキル棚卸し

- 廃止: `herdr` / `goal` / `git-semantic-commit`。
- 改名: `thinkpad-resident` → `http-resident`（`open-artifact` の参照も更新）。
- 保留: `add-to-todo`。
- `bin/link-dotfiles-macos.sh` の `agents/skills/herdr` リンクを削除。

**2026-10-21 実行**: 3スキルを削除（`herdr` は必要になったら git 履歴から復旧する方針）。
`git-semantic-commit` の実質3行（意味で分割 / `git add -A` 禁止 / push は明示時のみ）は `rules/artifacts.md` §4 へ移設。
リンク削除は `bin/link-dotfiles-macos.sh` と `~/.gemini/config/skills/herdr` の両方。
**改名は取りやめ**: 同名のコマンド `thinkpad-resident` が `~/.local/bin` に実在し、`open-artifact` もそのコマンド名で呼ぶため、
スキル名だけ変えると文書と実体が食い違う。改名するなら CLI 本体と両マシンのリンクまで同時に動かす必要がある。

### Phase 5: cursorrules / docs / HTML 整理

- `agents/docs/*.html` を削除（参照ゼロを確認済み）。
- `docs/ai-cli-invocation-guide.md` を削除、または3行に圧縮。
- `cursorrules` の最終確認。

**2026-10-21 実行**: `ai-cli-invocation-guide.md`（139行）は削除。残す価値があったのは実行時の罠だけで、
`rules/delegation.md` §5 に移設した（`</dev/null` 必須 / `agy` の `-p` 順序 / YOLO フラグの差 / OpenCode の `#none`）。
モデル一覧とテンプレートは `docs/routing.md` と重複していたため落とした。

## 6. 検証コマンド

```bash
# 禁止記法
git grep -nE "§|RULE\[" -- agents/GLOBAL_RULES.md agents/rules/

# リンク切れ（相対パス）
git grep -nE "file:///|/Users/|/home/" -- agents/GLOBAL_RULES.md agents/rules/

# クォータ
~/dotfiles/bin/update-ai-usage --format markdown --no-notify --no-write-runcat

# 注入確認（OpenCode）
opencode run --standalone -m opencode/deepseek-v4.1-flash-free \
  "あなたに注入された指示文書の1行目だけを引用してください。"
```

## 7. 未決事項

- `docs/routing.md` の作成を Phase 2 に前倒すか、Phase 3 のままにするか。
- Claude Team の消費速度が未測定。日常でどこまで `claudeAgent` を使うか。
- Argon 残 34% をいつ・何に使い切るか。

## 8. 参照

- `agents/GLOBAL_RULES.md`
- `agents/rules/*.md`
- `agents/glossary.md`
- `agents/skills/model-route/SKILL.md`
- `research-brain/wiki/ai-engineering/user_model_routing_mental_model.md`
