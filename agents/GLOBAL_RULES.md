# Global AI Agent Rules (Tier 0)

すべてのプロジェクトに常時適用される最小ルール。プロジェクト固有の `AGENTS.md` / `CLAUDE.md` が優先する。
詳細は必要時に `~/dotfiles/agents/rules/` を読む（下の参照表）。

## 1. 安全・禁止

- **HPC**: 生の `sbatch` / `qsub`、Miyabi / Pegasus / Sirius への `ssh` / `scp` / `rsync` は禁止。必ず harness 経由（`ppx_harness` / `miyabi_harness --dry-run`）。実ログインは人間。→ `rules/hpc.md`
- **高額 API**: 明示指示なしに Anthropic / OpenAI の従量 API を使わない。サブスク枠を優先する。→ `rules/models.md`
- **破壊的 git**: `push --force` / `reset --hard` / 共有ブランチの書き換えは、明示指示があるときだけ。

## 2. 委譲

- 子エージェントの失敗を、親がインラインで引き受けてはならない（コンテキスト分離が壊れる）。
- 実装と検証は異種モデル・別コンテキストで行う（Maker-Breaker）。
- 指定されたモデルを勝手に昇格・降格しない（Strict Model Fidelity）。
- 子には会話履歴が渡らない。brief に前提・制約・完了条件を全部書く。
- → `rules/delegation.md`

## 3. 成果物

- 人間レビュー用 HTML は `wiki/`、作業ログは `logs/` または `scratch/`、図表は `images/`。
- プロジェクトルートを作業ログで汚さない。`README.md` には最終結果だけ書く。
- → `rules/artifacts.md`

## 4. リンク・出力

- `file:///` とホスト絶対パス（`/Users/...`）を、チャットにもファイル内にも書かない。
- ファイルは相対パスまたは `[[WikiLink]]`。ブラウザ成果物だけ `http://...` で示す。→ `rules/links.md`
- 論文・投稿・教員説明に触れる応答は、到達レベルと不足を明示する。→ `rules/paper.md`

## 5. スキル・用語

- 該当タスクの前に `~/dotfiles/agents/skills/<name>/SKILL.md` を読む。
- 略称は `~/dotfiles/agents/glossary.md` を正本とする。

## 参照表

| 状況 | 読むファイル |
|---|---|
| モデル選択・クォータ・敵対レビュー | `rules/models.md` |
| 委譲・サブエージェント・CLI フォールバック | `rules/delegation.md` |
| HPC・クラスタ | `rules/hpc.md` |
| 成果物・ログの置き場 | `rules/artifacts.md` |
| リンク記法 | `rules/links.md` |
| 論文・説明の粒度 | `rules/paper.md` |
| Cursor 固有 | `rules/cursorrules` |
| 略称 | `glossary.md` |
