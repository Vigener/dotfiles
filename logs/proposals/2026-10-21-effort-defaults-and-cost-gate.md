# 提案: effort の既定値と、サブスク枠のコストゲート

> 提案書。正本ではない。実装は `b141ce59`（agents ルール再編スレッド）が settle した後に、同スレッドから行う。
> 本書は別スレッド（`a74bd965`）で作成した。`agents/` 配下は編集していない。

## 0. 発端（実測）

`b141ce59` の bakeoff 採点で、2分以内に3体の高コスト子を起動していた。

| 時刻 | 子 | provider | model | effort |
|---|---|---|---|---|
| 06:36 | bakeoff blind judge | claudeAgent | claude-sonnet-5-5 | **high（明示）** |
| 06:38 | bakeoff judge sonnet official | claudeAgent | claude-sonnet-5-5 | **high（明示）** |
| 06:38 | bakeoff judge argon official | antigravity | gemini-4-argon-**high** | slug に埋込 |

- Sonnet 2体は同一モデル・同一親・2分差。このタスク全体で 5h 枠の約 4%（ユーザー実測）。
- Argon の週枠は残 26.5% 相当（バー 3/12、ペース 1.24x、リセット 2d20h）。ペースは超過気味。
- どちらも事前の許可宣言なし。

## 1. 機構の事実（ここが本質）

| provider | モデル | effort の持ち方 | 無指定のとき |
|---|---|---|---|
| claudeAgent | claude-sonnet-5-5 | `options: [{id:"effort", value:...}]` | **high**（isDefault） |
| claudeAgent | claude-opus-5-5 | 同上 | **medium**（isDefault） |
| claudeAgent | claude-fable-5-1 | 同上 | **medium**（isDefault） |
| antigravity | gemini-4-argon-{low,medium,high} | **モデル ID そのもの**（options 空） | ID で決まる |

つまり:

1. **Sonnet は「effort を書かない」が high を意味する。** Opus は同じ書き方で medium。モデルごとに無指定の意味が違う。
2. **Argon は effort がモデル ID。** 規則に `gemini-4-argon-high` と書いた瞬間、その規則を読んだエージェントは全員 high を選ぶ。`medium` / `low` も別 ID として存在する。
3. `docs/routing.md` の役割表（設計・仕様化 / 敵対レビュー）が `Gemini 4 Argon (high)`、環境契約の行が `gemini-4-argon-high` のみ。`delegation.md` の呼び出し例も `-high`。
4. `routing.md` の Claude 5.x 表は Sonnet を `effort: medium` と書いているが、役割表では effort 無指定。**同じファイル内で Sonnet の effort が2通り**。

結果: 「Sonnet を使う」＝ high、「Argon を使う」＝ high が、意図ではなく**記法の副作用**として既定化していた。

## 2. なぜ「申請」が消えたか（ゲートの所在）

現行で許可が要るのは3つだけ。

| ゲート | 場所 | 対象 |
|---|---|---|
| 従量 API の明示指示 | `GLOBAL_RULES.md` 安全・禁止 | Anthropic / OpenAI の**API 課金** |
| Cursor から Fable / Opus | `models.md` / `routing.md` | Cursor の**核ボタン** |
| Sonnet 5 / Terra は要許可 | `skills/adversarial-review/SKILL.md` | その**スキルの手順内**だけ |

サブスク枠（Argon 週枠・Claude Team）は**どの層にもゲートが無い**。加えて `models.md` の「Argon は Use it or lose it、日常4大門番に最優先投入」が、ゲート撤廃として読める。さらに slug が `-high` 固定なので「Argon を投入」＝「high で投入」になる。

**「申請式」の記憶は正しいが、それはスキルの中にしか無かった。** スキルを通らない呼び出し（今回の採点）は素通りする。

## 3. 方針案: effort は「成功条件が閉じているか」で決める

モデルごとの High/Medium 論は不毛。効くのは**タスクの性質**。

| 成功条件 | effort | 例 |
|---|---|---|
| **閉じている**（ルーブリック・DoD・テスト・差分がある） | **medium** | Diff 監査、採点、仕様適合検査、テスト生成（条件が明示済み） |
| **開いている**（何が良いか自体を決める） | **high** | 仕様策定、発想の再設計、袋小路の裁定、章立て |
| **機械的** | **low** | 整形、分類、抽出、要約 |

この規則は Argon にも Sonnet にも Opus にも同じに当てる。**モデルは「誰が」、effort は「どれだけ考えるか」で、別軸。**

### 原則: 深さより本数（medium × 2 > high × 1）

見落としは「1体が深く考える」より「別モデルが独立に見る」方が減る、という前提を置く（2026-10-21 のユーザー判断）。

- 敵対レビューの既定は **medium の2本立て**（例: Argon medium + Sonnet medium）。high 1本にしない。
- 根拠: high は同じモデルの注意を厚くするだけで、**探索の方向は増えない**。別ファミリーは失敗の仕方が違うので、和集合の取りこぼしが減る。
- 副作用: コストは概ね「medium × 2 ≒ high × 1」。本数で買う方が、品質の分散も小さい。
- 例外: 2本目を足すと brief の管理が破綻するほど重い案件（長大な設計文書など）は1本にして、effort ではなく**分割**で解く。

### 個別の答え

**Argon**: 既定は **medium**。**high は原則使わない。** 「開いている」案件のうち、発想の再設計が本当に要るものは **Opus / Fable（要許可）** の仕事であり、Argon の high で代替しない。
→ 「Argon は基本 high」は**根拠がない**。根拠にしていたのは週枠の使い切り規律だが、使い切る対象は「枠」であって「effort」ではない。
→ 重要な局面で Argon 単体の意見を信用する運用は、そもそも取らない（2本立てにする）。

**Sonnet**: 既定は **medium**（`routing.md` の Claude 表と一致）。high は開いた案件のみ。実装（W3）は DoD があるので medium が妥当。今回の採点はルーブリックがあったので、同じ規則なら medium。
→ 「Sonnet は medium だと弱い」という証拠は、いま手元に無い。あるのは「既定が high だから high で動いていた」という事実だけ。**弱い/弱くないは未検証**。

**Opus**: 既定 medium。監査で high にするのは、不変条件が絡む裁定のみ。

## 4. 承認ゲート（1行・per-call）

**対象**: 1タスクで 5h 枠の概ね 2% 以上、または週枠の概ね 5% 以上を消費しうる呼び出し。サブスク枠も対象。従量 API は従来どおり明示指示必須。

**形式**（呼ぶ直前に1行、ユーザーの OK を待つ）:

```text
[委譲] model=claude-sonnet-5-5 effort=medium / pool=Claude Team / 推定=5h枠の約2% / 目的=ベイクオフ採点 — 実行してよい？
```

**規則**:

1. 許可は **呼び出し単位**。「Argon を使ってよい」は「Argon を何回でも」ではない。
2. **「検証のため」は免除理由にならない。** 消費する枠が同じならゲートを通す。
3. 同じモデル・同じ役割を短時間に2回呼ばない（再実行が要るなら理由を1行書く）。今回の Sonnet 2体はこれに当たる。
4. 無料枠（Free / inherit）はゲート不要。
5. ユーザーが指示の中で名指しした場合は、その1回分の許可とみなす。

### 据え置き（確定）

- **Opus / Fable の許可制は維持する。** effort を medium にしても解除しない。Claude Team では Fable が使えないため、Fable は Cursor の Other Models を想定する。
- 理由: 高額・核ボタンに近いものは、effort の既定値ではなく**別のゲート**で守る。effort の話と権限の話を混ぜない。

### 要検討: Opus medium in claude

Opus は無指定でも medium なので、「medium なら無許可」にすると実質ノーゲートに近づく。3案。

| 案 | 内容 | 長所 | 短所 |
|---|---|---|---|
| A | 据え置き（Opus は全部許可制） | 事故ゼロ | 裁定のたびに止まる |
| B | medium のみ無許可、high 以上は許可制 | 実用速度 | 「medium のつもりが high」の取り違えが起きると素通り |
| C | 裁定・袋小路の役に限り medium を無許可 | 役割で線を引ける | 「裁定」の自己申告に依存 |

現時点の推奨は **A**。B/C は、Opus medium の実消費が1回あたり 5h の何 % かを測ってから決める。

## 5. 差し替え文面

### 5.1 `agents/rules/models.md` に新設（方針）

```markdown
## 3.5 effort の既定値

- 既定は **medium**。high は「成功条件が開いている」案件だけに使う。
- 閉じている（ルーブリック・DoD・テスト・差分がある）: medium。
- 開いている（何が良いか自体を決める）: high。
- 機械的（整形・分類・抽出）: low。
- モデルと effort は別軸。モデルを上げる前に effort を下げられないか考える。

| provider | 無指定のときの effort | 対処 |
|---|---|---|
| claudeAgent の Sonnet | **high** | `options` で medium を明示する |
| claudeAgent の Opus / Fable | medium | 明示不要。high にするときだけ書く |
| antigravity の Argon | モデル ID で決まる | `gemini-4-argon-medium` を既定にする。high は明示的な判断としてのみ |

### 3.6 サブスク枠のコストゲート

- 1タスクで 5h 枠の約 2% 以上、または週枠の約 5% 以上を消費しうる呼び出しは、**事前に1行で宣言して許可を取る**。サブスク枠も対象。
- 許可は呼び出し単位。「検証のため」は免除理由にならない。
- 同じモデル・同じ役割の短時間の再呼び出しは、理由を1行書く。
```

### 5.2 `agents/docs/routing.md` の修正

- 役割表の `Gemini 4 Argon (high)` を `Gemini 4 Argon (medium)` に。high は条件列に逃がす。
- 敵対レビューの行を「**Argon medium + Sonnet medium の2本立て**」に変える。high 1本を既定にしない。
- 環境契約の `argon in agy` を `gemini-4-argon-{medium|high}` に（`-high` 単独にしない）。
- 判定順序の「Phase-First Override で最高峰を投入」に「effort も high にする」と書かない（モデルと effort は別軸）。
- Sonnet の effort を役割表でも medium に揃える（Claude 5.x 表との二重記述を解消）。

### 5.3 `agents/rules/delegation.md` の呼び出し例

`gemini-4-argon-high` → `gemini-4-argon-medium`。high を使う条件を1行添える。

### 5.4 `agents/skills/adversarial-review/SKILL.md` の整合

現行スキルは「Sonnet 5 と Terra を同じレビュー役で並べない（同役二重禁止）」と「Sonnet 5 は要許可」。新しい方針と**正面から矛盾する**ので、ここを直さないと現場で止まる。

- 「同役二重の禁止」を **「high の同役二重は禁止。medium の別ファミリー2本立ては可（推奨）」** に変える。
- 許可表を **Sonnet 5 medium = 許可不要（既定）／Sonnet 5 high = 要許可／Opus・Fable = 要許可** に組み替える。**Terra は表ごと削除する**（5.5）。
- 「発想・方針・問いの立て直し」の担当を Sonnet 5 から **Opus / Fable（要許可）** に移す。Sonnet は発想役にしない。
- T3 ティアの「未許可なら agy Sonnet 4.6 で止める」は、**Sonnet 5 medium で止める**に更新する。

### 5.5 GPT-5.6 Terra の運用撤退（2026-10-21 決定）

> **更新（2026-10-21 追記）**: 対象は Terra 単体ではなく **GPT 系全体（Sol / Terra / Luna）** に拡大した。
> Cursor の Other Models は Fable 専用とし、第三系統は採用しない。実装は `logs/proposals/` の外
> （`adversarial-review` の表削除、`delegation.md` の通称リスト、履歴1行）で完了。本条は経緯として残す。

**事実**: `gpt-5.6-terra` は T3 のカタログで **`cursor` ドライバにしか存在しない**（`codex` はモデル未設定、`antigravity` には無い）。Cursor では「Other Models」枠の消費で、その枠は Fable 5.1 と共有。実測時点で Other Models は枯渇（0.0%）。

**判断**: 運用面からは**モデル名ごと削除**する。スペック表だけ残すと、エージェントは「第三のファミリー」を探して Terra に到達し、Fable 用の枠を食う。死んだ選択肢は無害な記述ではなく**能動的な危険**。

削除対象（判断に使う面）:

| ファイル | 箇所 |
|---|---|
| `agents/skills/adversarial-review/SKILL.md` | frontmatter の description、要許可モデル、役割表、T3 ティア、手順1、手順の最終段 |
| `agents/rules/delegation.md` | 通称リスト（Terra / Sol / Luna） |
| `docs/ai-cli-invocation-guide.md` | Terra / Sol の行（Phase 5 の削除対象でもある） |

残す対象（履歴）:

- `agents/docs/user_model_routing_mental_model.md` に**1行だけ**:
  「GPT-5.6 Terra は Cursor の Other Models 経由のみ。Fable と同じ枠を奪い合い、コストに見合わないため 2026-10-21 に運用から外した。」

**一般化（同じ判断を繰り返さないための不変条件）**:

- **Cursor の Other Models は Fable 専用**。Sol / Luna / Terra は対象外。
- 「統合判定・ルーブリック横断」の代替は、新モデルを足さず **Opus medium（要許可）または Argon medium** で行う。
- 異種ファミリーは **Gemini（Argon）+ Anthropic（Sonnet）の2系統で足りる**とする。第三系統は、この枠が空いてから再検討する。

## 6. 未決（実測が要る）

- **medium × 2 が high × 1 の見落としを実際に減らすか**は未検証。手順は「同じ diff・同じ brief で、Argon medium と Sonnet medium を走らせ、既存の Argon high 採点（2026-10-21 06:38 の bakeoff judge）と major 指摘の集合を比べる」。high を新たに呼ばないので、追加コストは medium 2本だけ。
- 閾値（5h の 2% / 週の 5%）は仮。Sonnet 採点1回＝約4%という1点だけが根拠。上の実験で medium の実消費も同時に取れる。
- `docs/user_model_routing_mental_model.md` には `-high` 前提の記述が残る。歴史文書として残すなら、冒頭に「effort の既定は medium（`rules/models.md`）」の1行が要る。

## 7. 実装手順（`b141ce59` 側）

1. 5.1 / 5.2 / 5.3 を適用。
2. `models.md` と `routing.md` で Sonnet の effort 記述が一致していることを確認。
3. `git grep -n "argon-high" -- agents/` の残存を確認し、意図した箇所だけに減らす。
4. commit はパス明示。`docs(agents): default effort to medium and gate subscription-pool calls`。
