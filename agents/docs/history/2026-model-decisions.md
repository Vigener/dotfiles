# モデル運用の決定と撤回（2026年）

> 規範ではない。規範は `rules/models.md`（方針）と `docs/routing.md`（対応表）。
> 事故の再発防止は `docs/lessons.md`。数値（残量）は書かない。残量は `update-ai-usage` で見る。

## 1. 契約の経緯（なぜ Cursor Pro を維持するか）

- 2026-10、Claude Pro 乗り換え・ChatGPT Plus 乗り換えを検討したが、既に使い込んだ Cursor Pro の
  利用実績と xAI 統合の不透明さを踏まえ、**Cursor Pro を維持**する決定をした。
- その後の枠の逼迫と Argon 独立週枠の解放により、設計・監査は agy（Argon）、打鍵は Cursor（Composer）
  という分担に落ち着いた。現在の配分は `rules/models.md`。
- 月枠は「更新日の約1週間前に切れる」ペースを理想とする。残して捨てるのが最大の損失。
- 2026-10-21、**Sonnet は agy、Opus は Team** に分けた。agy 側の Claude 週枠は減りが早く、
  途中で止まると作業が切れるため（研究用の Team 枠を生活タスクで食わないための線引きでもある）。

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
  ただし予算は月 $2 に固定（`rules/models.md` §2.5）。
