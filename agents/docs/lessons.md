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
- 無指定の罠（Sonnet は high、Opus / Fable は medium）は `rules/models.md` §3.5 の表を見る。

## 4. 残量を読むときは生の値を見る（2026-10-21）

- `update-ai-usage` の Markdown 表示が、Claude のセッション枠を「0% left」と出したが、
  JSON の `limits[].percent` は 4% だった。**表示だけを信じて「今日は詰んでいる」と判断しない。**
  2026-10-21 に修正（`limits[]` を優先するようにした）。古いキャッシュが残っている間は
  最大15分だけ古い値を出すので、変だと思ったら `--format json` の `limits` を見る。

## 5. ルールを変えても届かない範囲（2026-10-21）

システム指示は**プロセス起動時に読んで以後保持**される。境界はファイルの更新時刻ではなく、プロセスの寿命。

| 経路 | 保持単位（実測） | 効かせ方 |
|---|---|---|
| OpenCode（T3 経由の `opencode serve`） | **アプリ全体** | T3 を再起動 |
| OpenCode（CLI の常駐 `--service`） | サービス | `pkill -f 'opencode serve --service'` → 次回実行で再生成 |
| Claude（T3 の `claudeAgent`） | **スレッド**（`claude --input-format stream-json --session-id` が終了後も残る） | 新スレッド |
| Cursor（T3 の `cursor`） | ターン（`cursor-agent` は残らなかった） | 次ターン |
| Antigravity（T3 の ACP） | スレッドと推定（週枠 0% で未検証） | 新スレッド |
| CLI 直叩き（`claude -p` / `cursor-agent -p` / `agy -p`） | 実行ごと | 何もしなくてよい |

**OpenCode だけ手順が重い**（アプリ全体が古いルールを配るため）。

1. 作業の区切りで T3 を終了 → 起動する。
2. 確認: 新しいスレッドで「注入されている指示文書の1行目を引用して」と聞く。
   `# Global AI Agent Rules (Tier 0)` なら成功、`# Global AI Agent Rules` ならまだ古い。
3. CLI 側だけ古い場合: `pkill -f 'opencode serve --service'`。次に `opencode` を叩けば新プロセスが立つ（2026-10-21 17:59 に実測）。
4. モデル定義や MCP 設定は消えない（設定ファイルは起動時に読むだけ）。

`opencode run --standalone` は毎回新しいプロセスなので、CLI の検証はこれで足りる。

**補足**

- `claude` はターン終了後も**プロセスが残る**（実測: 完了2分後も生存）。だから同一スレッドの続きは古いルールのまま。
- `opencode` だけは**アプリ全体で1プロセス**なので、影響が全スレッドに及ぶ。ルール変更後は `pkill -f 'opencode serve'` → T3 再起動が確実。
- CLI 直叩き（`claude -p` / `cursor-agent -p` / `agy -p` / `opencode run --standalone`）は毎回新プロセスなので、そのまま最新。

## 6. Claude Team の 5h : 週 の消費比（2026-10-21 実測）

- 5h 枠の消費は、週枠の**約5〜7倍の速さ**。実測2点: `7% : 1%`（7:1）と `11% : 2%`（5.5:1）。
  目安は保守側の **5:1** で見る（5h 2% ≒ 週 0.4%）。
- 通常は **5h が先に当たる**（週枠が残り少ないときは週枠が律速になるので、両方見る）。
- 注意: モデル（Sonnet / Opus）・effort・キャッシュで変わる。断定せず、ズレたらこの節を更新する。

## 7. Codex は API キー環境で従量に落ちうる（2026-11-01）

- **`OPENAI_API_KEY`** やプロジェクトの **`.env`** にキーがあると、
  ChatGPT ログインより API キー認証が優先され、**従量課金**になる事例がある。
- `preferred_auth_method` は上流で**削除済み**の設定キー。代わりに **`codex login status`**
  が **`Logged in using ChatGPT`** であることを確かめ、子プロセスの環境から
  **`OPENAI_API_KEY` と `CODEX_API_KEY` を外す**（`bin/codex-sub` が行う）。
- **`codex login status` の表示文言**で ChatGPT と API キーを判別するロジックは、
  契約後に本人マシンで確認すること（`bin/codex-sub` は保守的ヒューリスティック）。
