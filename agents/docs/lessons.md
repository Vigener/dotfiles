# 教訓（事故と、その再発防止）

> 規範ではない。規範は `rules/models.md`（方針）と `docs/routing.md`（対応表）。
> 決定の経緯と、撤回した選択肢は `docs/history/2026-model-decisions.md`。

## 1. 委譲はコンテキスト分離のために行う

- 親の Context Rot を防ぎ、司令塔と作業役を分けるのが目的。**子の失敗を親がインラインで
  引き受けてはならない**（分離が壊れる）。CLI へは別プロセスでフォールバックする。
- 指定モデルの勝手な昇格・降格は禁止。追補は台帳の `childThreadId` へ。→ `rules/delegation.md`

## 2. T3 Code の設定を稼働中に書き換えると全スレッドが落ちる（2026-10-18）

- `~/.t3/userdata/settings.json` を稼働中に書き換えると、プロバイダのリロードで実行中セッションが
  強制終了する（書き込んだ側と無関係のスレッドも道連れになる）。`antigravity` に `customModels` を
  注入するのは仕様外。
- Claude は **agy（週枠）> cursor（月枠）> claudeAgent（従量）** の順。`claudeAgent` は明示指示が
  あるときだけ。agy の Claude は `delegate_task` に露出しないので CLI から呼ぶ。

## 3. Anthropic 5.x は「思考を切る」指定で 400 になる

- `thinking: disabled` / `tool_choice: any|tool` / Assistant Prefill は不可。軽くしたいときは
  `effort: low`。`Think step-by-step` は書かない。Haiku に `effort: max` を渡さない。
- 無指定の罠（Sonnet は high、Opus / Fable は medium）は `rules/models.md` 3.5 の表を見る。

## 4. 残量を読むときは生の値を見る（2026-10-21）

- `update-ai-usage` の Markdown 表示が、Claude のセッション枠を「0% left」と出したが、
  JSON の `limits[].percent` は 4% だった。**表示だけを信じて「今日は詰んでいる」と判断しない。**
  2026-10-21 に修正（`limits[]` を優先するようにした）。古いキャッシュが残っている間は
  最大15分だけ古い値を出すので、変だと思ったら `--format json` の `limits` を見る。
