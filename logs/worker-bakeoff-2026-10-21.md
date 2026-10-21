# Worker ベイクオフ: DeepSeek V4.1 Flash Free vs Composer 2.5（2026-10-21）

> 作業ログ。正本ではない。結論・限界・再現手順を残すための記録。
> クォータ数値は点時点の参考値であり SSOT ではない。必要時は
> `~/dotfiles/bin/update-ai-usage --format markdown --no-notify --no-write-runcat`
> で取得する。

## 0. 目的

W1（日常実装）の既定を **DeepSeek V4.1 Flash Free** のままにするか、
**Composer 2.5** に戻すかを、公平なベイクオフで確認する。

## 1. 公平性の設計

- **タスク設計**: Gemini 4 Argon (high)。Assistant は設計・隠しテスト・参照実装に関与しない。
- **実行**: Assistant はプロンプト配布、run ディレクトリ作成、diff 回収、機械集計のみ。
- **採点**: 2名。
  - **Sonnet 5.5**（`claudeAgent`, effort high）: 設計・実装に非関与。
  - **Gemini 4 Argon (high)**: タスク設計者。別方向のバイアス検査。
- **匿名化**: タスクごとに A/B の対応を混在。採点者にはモデル名を渡さない。
- **利益相反の明示**: Assistant 自身が DeepSeek Free。したがって単一採点者の結果では確定せず、
  公式配点（隠しテスト60 / スコープ15 / 品質15 / 整合性10）と2名の一致で判断する。
- **候補者への制約**: 自分の run 外を読まない、既存テストを変えない、commit しない、
  Python 3.11+ 標準ライブラリのみ、ネットワーク禁止。

## 2. タスク

| ID | 種類 | 内容 | 隠しテスト |
|---|---|---|---|
| T1 | バグ修正 | `log_window` のスライディングウィンドウ。順不同イベント、境界、未来時刻、p95、整形 | 5 |
| T2 | リファクタ | `config_pipeline` の重複4関数を `normalizer.py` へ抽出し、各ローダーから直接 import | 5 |
| T3 | 機能追加 | `task_scheduler` のスロット上限、タグの推移閉包、ID/型検証、CLI 終了コード | 4 |

各タスクの仕様・参照実装・隠しテストは `scratch/bakeoff/design/tasks/` に保存（git 管理外）。

## 3. 実行

- run: `scratch/bakeoff/runs/{t1,t2,t3}-{a,b}`。各 run は独立 git repo、base commit は同一ツリー。
- 候補者: `a` = **DeepSeek V4.1 Flash Free**（`opencode`）、`b` = **Composer 2.5**（`cursor`）。
- 1タスク・1モデル・1回。反復なし。
- 可視テストは候補者が実行。隠しテストは採点時に別コピーへ適用し、元 run は保持。
- 既存テスト改変の検査: `git diff -- tests/<元テスト>` が空であることを確認。
- 実行時間・コストは正確に取れていない（`task_status` に時刻が残らない）。

## 4. 機械結果

| タスク | モデル | 可視 | 隠し | 既存テスト改変 | 追加テスト | 残置物 |
|---|---|---|---|---|---|---|
| T1 | DeepSeek | 4/4 | 5/5 | なし | 9 | なし |
| T1 | Composer | 4/4 | 5/5 | なし | 0 | `__pycache__` |
| T2 | DeepSeek | 3/3 | 5/5 | なし | 12 | `__pycache__` |
| T2 | Composer | 3/3 | 5/5 | なし | 0 | `__pycache__` |
| T3 | DeepSeek | 3/3 | 4/4 | なし | 41 | なし |
| T3 | Composer | 3/3 | 4/4 | なし | 0 | `__pycache__` |

**機能面では両者同等**。隠しテストは合計 14/14、可視は 10/10。

## 5. 採点（解匿名化）

匿名マッピング:

| タスク | Candidate A | Candidate B |
|---|---|---|
| T1 | Composer (`b`) | DeepSeek (`a`) |
| T2 | DeepSeek (`a`) | Composer (`b`) |
| T3 | Composer (`b`) | DeepSeek (`a`) |

| タスク | DeepSeek (Sonnet / Argon) | Composer (Sonnet / Argon) | 判定 |
|---|---|---|---|
| T1 | 99 / 100 | 93 / 93 | DeepSeek（実質は同点） |
| T2 | 93 / 93 | 92 / 93 | 同点 |
| T3 | 99 / 100 | 89 / 93 | DeepSeek |
| 合計 | **291 / 293** | **274 / 279** | DeepSeek |

- 両採点者とも「T1 は DeepSeek、T2 は同点、T3 は DeepSeek」で一致。
- 初回の Sonnet 採点は README 欠落により独自ルーブリック。参考として
  `scratch/bakeoff/results/judge-sonnet-v1-own-rubric.md` に保存。公式採点は
  `scratch/bakeoff/judge/SCORES-sonnet.md` と `SCORES-argon.md`。

## 6. 解釈

1. **T1/T2 は実質同点**。コードの機能は同一で、差は追加テスト・docstring・`__pycache__` の有無。
   Sonnet 自身が「`__pycache__` を軽視すれば T1 は 100 対 99、T3 は 97 対 99」と明記。
   Argon も「`__pycache__` のスコープ減点を除くと 300 対 300」と明記。
2. **T3 だけ実質差**。Composer は `re.match` + `$` で `"a\n"` を通し、
   非文字列タグで `TypeError` → traceback になり得る。DeepSeek は `fullmatch` と型検査で塞ぐ。
   これは隠しテストが見逃した欠陥で、Sonnet が手動確認で発見した。
3. **追加テストは DeepSeek の強み**。T1 9件、T2 12件、T3 41件。Composer は0件。
   W1 の「編集→テスト→修正」ではプラス。ただし今回の公式配点では独立軸ではない。
4. **`__pycache__` はモデル品質ではない**。テスト実行時の環境要因。
   次回は `PYTHONDONTWRITEBYTECODE=1` を付け、採点前に除去する。

## 7. 決定

- **W1 の既定は DeepSeek V4.1 Flash Free のまま**。
  - 理由: $0、機能同等、T3 型の検証・CLI で堅い、追加テストを書く。
  - ただし「DeepSeek が全般的に上」ではない。T1/T2 は Composer と同等。
- **Composer 2.5 の位置づけ**:
  - Cursor ネイティブの大量打鍵・最小差分。
  - Free が不調（1017 / レート制限 / SLA）のときの代替。
  - T3 型の検証・CLI を振るなら、`fullmatch` と型検査を明示指示するか W3 に上げる。
- **T2 型の純リファクタ**: どちらでも可。可用性・コストで選ぶ。
- **Free のリスク**: 期間限定・SLA なし・OpenCode 内限定。1017 の反映は未確定。
  有料 `deepseek/deepseek-flash`（1017）をフォールバックに置く。

## 8. 限界

- 1タスク・1モデル・1回。分散・再現性は未評価。
- 隠しテストが小さい（4〜5件）。T3 の `a\n` は隠しテストで検出できず、手動レビューで発見。
- タスクは小規模（数十行〜数百行）。大規模リポジトリの文脈保持は未評価。
- 実行時間・トークン・コストを正確に測っていない。
- 品質点は主観。差は 1〜4 点で、重みに敏感。
- 初回採点は README 欠落。公式ルーブリックで再採点済みだが、プロセス欠陥として記録。
- テスト整合性は Assistant の `git diff` で確認。採点者は独立検証していない。
- 追加テストの mutation testing は未実施。

## 9. 再現

```bash
# run の作成（例: T1）
mkdir -p scratch/bakeoff/runs/t1-a
cp -a scratch/bakeoff/design/tasks/t1/base/. scratch/bakeoff/runs/t1-a/
cp scratch/bakeoff/design/tasks/t1/SPEC.md scratch/bakeoff/runs/t1-a/TASK.md
git -C scratch/bakeoff/runs/t1-a init -q
git -C scratch/bakeoff/runs/t1-a add -A
git -C scratch/bakeoff/runs/t1-a -c user.email=bakeoff@local -c user.name=bakeoff commit -qm base

# 隠しテストの適用（元 run は保持）
cp -a scratch/bakeoff/runs/t1-a scratch/bakeoff/eval/t1-a
cp scratch/bakeoff/design/tasks/t1/tests_hidden/*.py scratch/bakeoff/eval/t1-a/tests/
(cd scratch/bakeoff/eval/t1-a && PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -p "test_window_hidden.py" -v)
```

- 採点パッケージ: `scratch/bakeoff/judge/`。
- 匿名マッピング: `scratch/bakeoff/mapping.json`（採点者には渡さない）。
- 生ログ: `scratch/bakeoff/results/`。
- `scratch/` は git 管理外。必要な場合は別途アーカイブする。

## 10. 次

- Phase 3（`agents/docs/user_model_routing_mental_model.md` の分割・数値撤去）は
  ユーザーの明示許可待ち。
