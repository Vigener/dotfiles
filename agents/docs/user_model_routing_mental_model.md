# モデル運用の決定と教訓（履歴・非規範）

> **これは規範ではない。** 規範は `rules/models.md`（方針）と `docs/routing.md`（対応表）。
> 本書は「なぜその運用になったか」と「事故の記録」だけを持つ。数値（%・$）と残量は書かない。
> 記録: 2026-10-01 / 整理: 2026-10-21（Phase 3 前半）

## 1. 契約の経緯（なぜ Cursor Pro を維持するか）

- 2026-10、Claude Pro 乗り換え・ChatGPT Plus 乗り換えを検討したが、既に使い込んだ Cursor Pro の
  利用実績と xAI 統合の不透明さを踏まえ、**Cursor Pro を維持**する決定をした。
- その後の枠の逼迫と Argon 独立週枠の解放により、設計・監査は agy（Argon）、打鍵は Cursor（Composer）
  という分担に落ち着いた。現在の配分は `rules/models.md`。
- 月枠は「更新日の約1週間前に切れる」ペースを理想とする。残して捨てるのが最大の損失。

## 2. 撤退・却下した選択肢（再提案を止めるための記録）

- **GPT 系（Sol / Terra / Luna）**: Cursor の Other Models 経由のみ。Fable 5.1 と同一プールを
  奪い合い、かつ OpenAI は Cursor へのモデル提供を終了する方針（移行期限は 2026-11-12 とされる。
  この外部事実はユーザー提供の参考情報で、一次確認は取っていない）。代替は Codex 拡張または
  自前 API キー（Tab / Auto / Cloud Agents / CLI では使えない）。2026-10-21 に運用から外した。
  **Cursor の Other Models は Fable 専用。異種ファミリーは Gemini（Argon）＋ Anthropic（Sonnet）の
  2系統で足りる。第三系統はこの枠が空いてから再検討する。**
- **OpenRouter 移行**: 2026-10-14 に Grok 4.7 の敵対レビューで全面棄却。定額モデルで足りている、
  オフピーク割引が消える、ホスト分散で品質と経路が読めない、端数のために認知負債を増やす。
- **Grok 4.7 を日常の思考・設計の主軸にする**: Cursor 月枠を食い潰したため 2026-10-16 に撤回。
- **Gemini 3.1 Pro / Claude Haiku 5.5**: 前者は 3.8 Flash と Argon に挟まれ選択理由が無い。
  後者は配管なら Flash で足り、Claude 枠を割く価値が無い。
- **DeepSeek 従量口座のゼロ化**: 2026-10-21 に `dsh-sub` を配備したため保留（試験運用）。

## 3. 教訓（事故と、その再発防止）

### 3.1 委譲はコンテキスト分離のために行う

- 親の Context Rot を防ぎ、司令塔と作業役を分けるのが目的。**子の失敗を親がインラインで
  引き受けてはならない**（分離が壊れる）。CLI へは別プロセスでフォールバックする。
- 指定モデルの勝手な昇格・降格は禁止。追補は台帳の `childThreadId` へ。→ `rules/delegation.md`

### 3.2 T3 Code の設定を稼働中に書き換えると全スレッドが落ちる（2026-10-18）

- `~/.t3/userdata/settings.json` を稼働中に書き換えると、プロバイダのリロードで実行中セッションが
  強制終了する（書き込んだ側と無関係のスレッドも道連れになる）。`antigravity` に `customModels` を
  注入するのは仕様外。
- Claude は **agy（週枠）> cursor（月枠）> claudeAgent（従量）** の順。`claudeAgent` は明示指示が
  あるときだけ。agy の Claude は `delegate_task` に露出しないので CLI から呼ぶ。

### 3.3 Anthropic 5.x は「思考を切る」指定で 400 になる

- `thinking: disabled` / `tool_choice: any|tool` / Assistant Prefill は不可。軽くしたいときは
  `effort: low`。`Think step-by-step` は書かない。Haiku に `effort: max` を渡さない。
- 無指定の罠（Sonnet は high、Opus / Fable は medium）は `rules/models.md` 3.5 の表を見る。
