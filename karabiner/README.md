# Karabiner-Elements 設定

## 主な割り当ての意図

- 英数キーをモディファイア化し、英数レイヤーでカーソル移動や編集操作を行えるようにする
- かなキーをモディファイア化し、かなレイヤーでメディア操作やアプリ起動を行えるようにする

## 検討中の点

- MacBook Air内蔵キーボードと、HHKB Studioの`Cmd`, `Opt`が逆問題を解決する。
  - おそらく、内蔵キーボードに合わせる方が自然な気がする。
  - ただし、デバイス毎に設定を分けることで、両立できると考えられるため、実装検討中。

## メモ（キー割り当ての決定経緯など）

- **AIエージェントへの "continue" / "yes" 送信を「かな＋Enter」「Shift＋かな＋Enter」にした理由**
  - T3 Code、Antigravity、Cursor、Ghostty / cmux などのAIエージェント環境において、処理継続を促す "continue" や、ゲート審査・危険操作確認に対する "yes" の送信頻度が極めて高い。
  - **通常送信（前進）**: 右親指（かなキー）＋ 右小指（Enterキー）で `continue` をノールック送信。
  - **修飾付き送信（承認・一段強いGO）**: 右親指（かなキー）＋ 右小指（Shift & Enter同時押し）で `yes` を送信。
  - 音量系（U:アップ, I:ダウン, Y:ミュート）のマッスルメモリーを一切破壊せず、右手Enter周辺に「AIエージェントへの送信系」を綺麗に集約。
  - 日本語入力中（IME ON）でも誤作動しないよう、キー送信シーケンスの先頭に `japanese_eisuu`（英数キー）を挟むことで、全角未確定にならず確実に半角で送信できるようにした。

- **右パネル開閉（Cmd+Opt+B）を「Shift＋英数＋B」にした理由**
  - T3 Code や VSCode において、左サイドバー（Cmd+B）は「英数＋B」でトグルできるが、補助サイドバー / 右パネル（PRレビュー、差分表示など）を開く「Cmd+Opt+B」は3キー同時押しで運指が窮屈だった。
  - 「英数＋B ＝ 左サイドバー」、「Shift＋英数＋B ＝ 右パネル」として B キー周辺にパネル開閉を集約。
  - なお、Mac標準の物理ショートカット `Cmd+Shift+B`（Chrome等のブックマークバー表示）は物理キーでそのまま機能するため、既存の操作感を損なわない。

- **Zoom を「かな＋Z」にした理由**
  - Zed は使用頻度が月0回になり、必要時も Cursor で足りる。一方 Zoom は週1のチームMTGで必ず使い、その 1.5〜2 時間だけ他アプリとの行き来が頻発する。
  - 初期立ち上げウィンドウは消す運用なので、PowerPoint のようなウィンドウサイクルは不要。既存の `toggleApp`（前面なら Cmd+H、それ以外は起動）でトグルする。
  - 起動名は `zoom.us`（`open -a Zoom` は失敗する）。Zed の Bundle ID はレジストリに残す。

- **Reasonable Size を「かな＋R」「Option＋R」にした理由**
  - 従来「かな＋R」に割り当てていた Preview（プレビュー）は、Finder や Slack 等のファイルを開く動作から立ち上がることが大半で、キーボードから直接単体起動するユースケースが皆無だった（Bundle ID は資産としてレジストリに温存）。
  - 一方で、ウィンドウを適切なサイズに中央配置する Raycast の "Reasonable Size" は日常的に高頻度で実行しており、これまで「Raycast起動 → re とタイピング → 実行」という手数を踏んでいた。
  - Raycast の Preset(Rectangle) では公式に `^⌥⌘R` (Ctrl+Opt+Cmd+R) が割り当てられており、Karabiner のかなレイヤー（K:最大化, ,:左半分, .:右半分, ;:Next Display, D:Display Preset）とウィンドウ操作の文脈が完全に一致し、「R = Reasonable Size」として記憶負荷なく直感的に叩けるため採用。併せて `Option+R` でも発火可能とした。

- **YouTube Music（ブラウザ5番目のタブ）を「かな＋8」にした理由**
  - 音量系操作（U:アップ、I:ダウン、Y:ミュート）との近さと、音楽という絶対的サブタスク（バックグラウンド用）であることから、できればノーlookで瞬間的に押したい作業であるため。
  - ノー・ルックで押しやすいキーを考慮すると、右手の中指と薬指を自然と伸ばした先にある「8」と「0」が候補として残った。その上で、UとIの上にある「8」を採用した。
  - 今後「かなキー＋数字」の割り当てが増える場合、基本的には「メインブラウザの先頭から何番目のタブにあるか」に数字キーを関連付けるのが無難。しかし、右手で押しづらい「1〜5」については、アルファベットキーに割り当てる方針とする（現に1〜4番目のタブはGemini, Hub, Slack, Calendarとしてアルファベットに割り当て済みであり、残り1つ程度であればアルファベットで賄えるはずであるため）。

- **英数＋数字（1..9）を Cmd+1..9 にした理由（T3 Code / ブラウザ対応）**
  - メイン作業環境となった T3 Code において、スレッド間の切り替えを親指（英数キー）起点で一意かつ素早く行うため。
  - 元々、英数レイヤーは「Cmdショートカットの模倣（Cmd+C/V/W/T/Z等）」を基本思想としているため、Mac標準や主要ブラウザ（Dia, Chrome, Zen 等）のタブ切り替え（Cmd+1..9）とも完全に挙動が一致し、直感的。
  - なお、従来の herdr (Ghostty) 用の `focus_agent` (Ctrl+Alt+1..9) は、Ghostty が前面にあるときのみ優先発火するようオーバライドし、以前の操作性も損なわずに維持した。

- **Option＋J を Cmd+J にした理由（ターミナル／パネルトグル）**
  - T3 Code、VSCode、Cursor 等の画面下部ターミナル（パネル）の開閉（Cmd+J）を、HHKB Studio の親指クラスタ（Cmdと英数の間にあるOption）からホームポジション（右手人差し指 J）のまま最小の負荷で実行できるようにするため。
  - 英数＋J（カーソル下移動）の一等地を侵害せず、macOS 標準の Option+J（特殊文字 ∆）を有効活用している。英数レイヤー中（英数＋Opt＋J）は段落移動が優先される。

## マッピング表

対象: karabiner/index.ts の現行有効ルール（コメントアウト行は除外）

### APP_VIVALDI

| ルール                                        | 入力            | 条件                                             | 出力           | 備考        |
| --------------------------------------------- | --------------- | ------------------------------------------------ | -------------- | ----------- |
| 【Vivaldi】英数+W/G で 専用ショートカット起動 | w + optionalAny | eisuu_pressed = 1 かつ App = com.vivaldi.Vivaldi | Ctrl+Opt+Cmd+W | Vivaldi専用 |
| 【Vivaldi】英数+W/G で 専用ショートカット起動 | g + optionalAny | eisuu_pressed = 1 かつ App = com.vivaldi.Vivaldi | Ctrl+Opt+Cmd+G | Vivaldi専用 |

### APP_GHOSTTY

| ルール | 入力 | 条件 | 出力 | 備考 |
| --- | --- | --- | --- | --- |
| 【Ghostty】英数+Ctrl+HJKL/V/-/Q/D を herdr 向けに変換 | Ctrl+D | eisuu_pressed = 1 かつ App = com.mitchellh.ghostty | Ctrl+Alt+Shift+D | file-viewer。Rectangle の Ctrl+Opt+D と分ける |
| 【Ghostty】英数+Ctrl+HJKL/V/-/Q/D を herdr 向けに変換 | Ctrl+H | eisuu_pressed = 1 かつ App = com.mitchellh.ghostty | Ctrl+Alt+Shift+H | pane 左 |
| 【Ghostty】英数+Ctrl+HJKL/V/-/Q/D を herdr 向けに変換 | Ctrl+J | 同上 | Ctrl+Alt+Shift+J | pane 下。Rectangle の左下 1/4 と分ける |
| 【Ghostty】英数+Ctrl+HJKL/V/-/Q/D を herdr 向けに変換 | Ctrl+K | 同上 | Ctrl+Alt+Shift+K | pane 上。Rectangle の右下 1/4 と分ける |
| 【Ghostty】英数+Ctrl+HJKL/V/-/Q/D を herdr 向けに変換 | Ctrl+L | 同上 | Ctrl+Alt+Shift+L | pane 右 |
| 【Ghostty】英数+Ctrl+HJKL/V/-/Q/D を herdr 向けに変換 | Ctrl+V | 同上 | Ctrl+Alt+Shift+V | 縦分割 |
| 【Ghostty】英数+Ctrl+HJKL/V/-/Q/D を herdr 向けに変換 | Ctrl+- | 同上（hyphen） | Ctrl+Alt+Shift+- | 横分割。Rectangle の縮小と分ける |
| 【Ghostty】英数+Ctrl+HJKL/V/-/Q/D を herdr 向けに変換 | Ctrl+Q | 同上 | Ctrl+Q | デタッチ（Ghostty が prefix+q）。Cmd+Q ではない |

Ghostty が前面のとき、左 Alt+Q / W / R は herdr の基準（Ctrl+Alt+1。英数+1 の直下）/ 前の Agent（prefix+comma）/ 次の Agent（prefix+period）。Opt+E（アキュートのデッドキー）は潰さない。同じ Q/W/R は、ブラウザ（Vivaldi / Chrome / Zen / Dia）では先頭タブ / 前のタブ / 次のタブ、Cursor と VSCode では第1グループ / 前のタブ / 次のタブ、Slack では未読一覧 / 前の未読 / 次の未読。

他アプリでは英数+Ctrl+HJKL は従来どおり（単語移動 / 高速スクロール）。英数+T は既存の Cmd+T（Ghostty では herdr 新規タブ）。英数+W は既存の Cmd+W（Ghostty では誤爆・連鎖消滅防止のため unbind。herdr の pane 閉じは由緒ある prefix `Ctrl+Space` → `x` または `exit` / `Ctrl+D` のみ）。英数+Q は Esc のまま。英数+Ctrl+Q は Ghostty のみデタッチ。タブ送りは Ctrl+Tab（Ghostty が prefix+n/p を送る）。

### APP_WARP

| ルール                                             | 入力       | 条件                       | 出力          | 備考     |
| -------------------------------------------------- | ---------- | -------------------------- | ------------- | -------- |
| 【Warp】Ctrl+Opt+HJKL -> Tmuxプレフィックス + 矢印 | Ctrl+Opt+H | App = dev.warp.Warp-Stable | Ctrl+B, Left  | Tmux操作 |
| 【Warp】Ctrl+Opt+HJKL -> Tmuxプレフィックス + 矢印 | Ctrl+Opt+J | App = dev.warp.Warp-Stable | Ctrl+B, Down  | Tmux操作 |
| 【Warp】Ctrl+Opt+HJKL -> Tmuxプレフィックス + 矢印 | Ctrl+Opt+K | App = dev.warp.Warp-Stable | Ctrl+B, Up    | Tmux操作 |
| 【Warp】Ctrl+Opt+HJKL -> Tmuxプレフィックス + 矢印 | Ctrl+Opt+L | App = dev.warp.Warp-Stable | Ctrl+B, Right | Tmux操作 |

### SYS

| ルール                                                | 入力                         | 条件 | 出力                                                              | 備考               |
| ----------------------------------------------------- | ---------------------------- | ---- | ----------------------------------------------------------------- | ------------------ |
| 【SYS】英数/かなキーをモディファイア化                | CapsLock + optionalAny       | なし | Left Option                                                       | CapsLockをOption化 |
| 【SYS】英数/かなキーをモディファイア化                | japanese_eisuu + optionalAny | なし | 変数 eisuu_pressed=1（押下中）, keyupで0, 単押しで japanese_eisuu | 英数レイヤーフラグ |
| 【SYS】英数/かなキーをモディファイア化                | japanese_kana + optionalAny  | なし | 変数 kana_pressed=1（押下中）, keyupで0, 単押しで japanese_kana   | かなレイヤーフラグ |
| 【SYS】右Cmdを右Shiftに変換（かな押下中は除外）       | right_command + optionalAny  | kana_pressed ≠ 1 | Right Shift                                                | 腱鞘炎対策。かな+Right Cmd は従来どおり |
| 【SYS】ろキー(international1)をバックスラッシュに変換 | international1               | なし | Option+international3                                             | JIS補正            |

### EDIT（英数レイヤー）

#### 例外ルール（修飾付き）

| 入力           | 条件              | 出力          | 意図                |
| -------------- | ----------------- | ------------- | ------------------- |
| Opt+H (+ any)  | eisuu_pressed = 1 | Opt+Left      | 左移動/左ジャンプ系 |
| Opt+L (+ any)  | eisuu_pressed = 1 | Opt+Right     | 右移動/右ジャンプ系 |
| Opt+J (+ any)  | eisuu_pressed = 1 | Opt+Down      | 下移動/段落系       |
| Opt+K (+ any)  | eisuu_pressed = 1 | Opt+Up        | 上移動/段落系       |
| Ctrl+H (+ any) | eisuu_pressed = 1 | Opt+Left      | 単語左移動          |
| Ctrl+L (+ any) | eisuu_pressed = 1 | Opt+Right     | 単語右移動          |
| Ctrl+J (+ any) | eisuu_pressed = 1 | Down x5       | 高速下スクロール    |
| Ctrl+K (+ any) | eisuu_pressed = 1 | Up x5         | 高速上スクロール    |
| Ctrl+S (+ any) | eisuu_pressed = 1 | Cmd+Up        | 文頭へ              |
| Ctrl+F (+ any) | eisuu_pressed = 1 | Cmd+Down      | 文末へ              |
| Ctrl+O (+ any) | eisuu_pressed = 1 | Opt+Backspace | 単語削除            |
| Ctrl+B (+ any) | eisuu_pressed = 1 | Cmd+Opt+B     | セカンダリサイドバー開閉 |
| Shift+B (+ any)| eisuu_pressed = 1 | Cmd+Opt+B     | 右パネル / 補助サイドバー開閉（T3 Code / VSCode等） |
| Ctrl+@ (+ any) | eisuu_pressed = 1 | Opt+Forward Delete | 次の単語削除（JIS: open_bracket） |
| Shift+Enter (+ any) | eisuu_pressed = 1 | Cmd+Shift+Enter | 送信・確定系（小指負担軽減） |
| Ctrl+[ (+ any) | eisuu_pressed = 1 | Cmd+Ctrl+[ | cmux 前ワークスペース等（JIS: close_bracket） |
| Ctrl+] (+ any) | eisuu_pressed = 1 | Cmd+Ctrl+] | cmux 次ワークスペース等（JIS: non_us_pound） |

#### 基本移動・編集

| 入力                | 条件              | 出力                      | 意図        |
| ------------------- | ----------------- | ------------------------- | ----------- |
| H + optionalAny     | eisuu_pressed = 1 | Left                      | カーソル左  |
| J + optionalAny     | eisuu_pressed = 1 | Down                      | カーソル下  |
| K + optionalAny     | eisuu_pressed = 1 | Up                        | カーソル上  |
| L + optionalAny     | eisuu_pressed = 1 | Right                     | カーソル右  |
| S + optionalAny     | eisuu_pressed = 1 | Cmd+Left                  | 行頭        |
| F + optionalAny     | eisuu_pressed = 1 | Cmd+Right                 | 行末        |
| O + optionalAny     | eisuu_pressed = 1 | Backspace                 | 1文字削除（左側） |
| @ + optionalAny     | eisuu_pressed = 1 | Delete Forward            | 1文字削除（右側）。JIS key_code: open_bracket |
| Q + optionalAny     | eisuu_pressed = 1 | Escape                    | ESC         |
| ; + optionalAny     | eisuu_pressed = 1 | Enter                     | Enter（小指負担軽減） |
| W + optionalAny     | eisuu_pressed = 1 | Cmd+W                     | タブを閉じる |
| Space + optionalAny | eisuu_pressed = 1 | Cmd+Space                 | Raycast起動 |
| D + optionalAny     | eisuu_pressed = 1 | Cmd+Left -> Shift+Cmd+Right | 一行選択    |

#### Cmdショートカット模倣

| 入力            | 条件              | 出力  | 用途            |
| --------------- | ----------------- | ----- | --------------- |
| Z + optionalAny | eisuu_pressed = 1 | Cmd+Z | Undo            |
| Y + optionalAny | eisuu_pressed = 1 | Cmd+Y | Redo / History  |
| X + optionalAny | eisuu_pressed = 1 | Cmd+X | Cut             |
| C + optionalAny | eisuu_pressed = 1 | Cmd+C | Copy            |
| V + optionalAny | eisuu_pressed = 1 | Cmd+V | Paste           |
| N + optionalAny | eisuu_pressed = 1 | Cmd+N | New             |
| A + optionalAny | eisuu_pressed = 1 | Cmd+A | Select All      |
| E + optionalAny | eisuu_pressed = 1 | Cmd+E | Quick Command等 |
| G + optionalAny | eisuu_pressed = 1 | Cmd+G | Find Next等     |
| R + optionalAny | eisuu_pressed = 1 | Cmd+R | Reload          |
| Ctrl+T (+ any)  | eisuu_pressed = 1 | Cmd+Opt+T | New Tab in Group |
| T + optionalAny | eisuu_pressed = 1 | Cmd+T | New Tab         |
| P + optionalAny | eisuu_pressed = 1 | Cmd+P | Print / Palette |
| B + optionalAny | eisuu_pressed = 1 | Cmd+B | Toggle Primary Sidebar（左サイドバー） |
| U + optionalAny | eisuu_pressed = 1 | Cmd+U | Underline 等（Shift併用で Cmd+Shift+U） |
| [ + optionalAny | eisuu_pressed = 1 | Cmd+[ | 戻る等（JIS key_code: close_bracket。Ctrl併用で Cmd+Ctrl+[） |
| ] + optionalAny | eisuu_pressed = 1 | Cmd+] | 進む等（JIS key_code: non_us_pound。Ctrl併用で Cmd+Ctrl+]） |
| / + optionalAny | eisuu_pressed = 1 | Cmd+/ | コメント切替    |

#### スクリーンショット

| 入力                 | 条件              | 出力             | 用途                               |
| -------------------- | ----------------- | ---------------- | ---------------------------------- |
| Ctrl+Shift+4 (+ any) | eisuu_pressed = 1 | Cmd+Shift+Ctrl+4 | 範囲キャプチャ（クリップボード）   |
| Shift+4 (+ any)      | eisuu_pressed = 1 | Cmd+Shift+4      | 範囲キャプチャ（保存）             |
| Ctrl+Shift+3 (+ any) | eisuu_pressed = 1 | Cmd+Shift+Ctrl+3 | 全画面キャプチャ（クリップボード） |
| Shift+3 (+ any)      | eisuu_pressed = 1 | Cmd+Shift+3      | 全画面キャプチャ（保存）           |

#### タブ・スレッド切り替え / herdr agent focus

| 入力              | 条件              | 出力         | 用途                                      |
| ----------------- | ----------------- | ------------ | ----------------------------------------- |
| 1..9 + optionalAny | eisuu_pressed = 1 かつ App = com.mitchellh.ghostty | Ctrl+Alt+1..9 | 【Ghostty】herdr `focus_agent`（直バインドと同系） |
| 1..9 + optionalAny | eisuu_pressed = 1 | Cmd+1..9     | 【全般】タブ・スレッド切り替え（T3 Code / ブラウザ等） |

### WINDOW（両親指レイヤー: 英数 + かな）

#### スペース・ウィンドウ操作 (最優先評価)

| 入力            | 条件                                 | 出力            | 想定アクション                          |
| --------------- | ------------------------------------ | --------------- | --------------------------------------- |
| H + optionalAny | eisuu_pressed = 1 かつ kana_pressed = 1 | Ctrl+Left       | 左のスペース                            |
| L + optionalAny | eisuu_pressed = 1 かつ kana_pressed = 1 | Ctrl+Right      | 右のスペース                            |
| J + optionalAny | eisuu_pressed = 1 かつ kana_pressed = 1 | Cmd+H           | 隠す                                    |
| K + optionalAny | eisuu_pressed = 1 かつ kana_pressed = 1 | Ctrl+Opt+Return | 最大化（Rectangle / Raycast）           |

### WINDOW（かなレイヤー）

#### ウィンドウ配置・スペース・ディスプレイ

| 入力                  | 条件                                                                 | 出力               | 想定アクション                          |
| --------------------- | -------------------------------------------------------------------- | ------------------ | --------------------------------------- |
| H + optionalAny       | kana_pressed = 1                                                     | Cmd+H              | 隠す（Hide・右手完結）                  |
| Left Arrow + optionalAny | kana_pressed = 1                                                  | Ctrl+Left          | 【フォールバック】左のスペース          |
| Right Arrow + optionalAny| kana_pressed = 1                                                  | Ctrl+Right         | 【フォールバック】右のスペース          |
| Down Arrow + optionalAny | kana_pressed = 1                                                  | Cmd+H              | 【フォールバック】隠す                  |
| Up Arrow + optionalAny   | kana_pressed = 1                                                  | Ctrl+Opt+Return    | 【フォールバック】最大化                |
| K + left_shift / right_shift | kana_pressed = 1                                                | Ctrl+Cmd+F         | フルスクリーン。Shift 付きを先に評価    |
| K + optionalAny       | kana_pressed = 1                                                     | Ctrl+Opt+Return    | 最大化（Rectangle / Raycast）           |
| R + optionalAny       | kana_pressed = 1                                                     | Ctrl+Opt+Cmd+R     | Reasonable Size（Raycast）               |
| , + optionalAny       | kana_pressed = 1                                                     | Ctrl+Opt+Left      | 左半分（Rectangle）                     |
| . + optionalAny       | kana_pressed = 1                                                     | Ctrl+Opt+Right     | 右半分（Rectangle）                     |
| / + left_shift / right_shift | kana_pressed = 1                                                | Ctrl+Cmd+F         | フルスクリーン。K の Shift と同じ       |
| / + optionalAny       | kana_pressed = 1                                                     | Ctrl+Opt+Return    | 最大化。K と同じ                        |
| ; + optionalAny       | kana_pressed = 1                                                     | Ctrl+Opt+Cmd+Right | Next Display（HHKB。Rectangle）         |
| : + optionalAny (quote) | kana_pressed = 1                                                   | Ctrl+Up            | Mission Control                         |
| international1 + optionalAny | kana_pressed = 1                                              | Ctrl+Opt+Cmd+Right | Next Display の名残。JIS ろ（HHKB / MBA 内蔵） |
| delete_forward + optionalAny | kana_pressed = 1                                              | Ctrl+Opt+Cmd+Right | Next Display（Conductor Del。Rectangle） |
| pointing button1      | kana_pressed = 1 かつ device vendor_id=0x1D50 product_id=0x615E | Ctrl+Opt+Cmd+Right | Next Display（Conductor MB1、L 右隣）   |
| D + optionalAny       | kana_pressed = 1                                                     | Cmd+Opt+Ctrl+Shift+D | Switch Display Preset                 |

#### ウィンドウ / アプリ切替

| 入力                       | 条件              | 出力              | 想定アクション |
| -------------------------- | ----------------- | ----------------- | -------------- |
| Right Cmd + optionalAny    | kana_pressed = 1  | Cmd+Opt+Tab       | Raycast Switch Windows を開く（選択型） |
| Tab + optionalAny          | eisuu_pressed = 1 | Tab（Opt は英数側でホールド） | AltTab 前進。英数を離すまで UI 維持。OS 標準 Cmd+Tab は温存 |
| Shift+Tab (+ any)          | eisuu_pressed = 1 | Shift+Tab（同上） | AltTab 後退（Tab を離してから Shift+Tab しても可） |

### WINDOW（Raycast Windows Management - グローバル）

| 入力  | 条件 | 出力               | 想定アクション                   |
| ----- | ---- | ------------------ | -------------------------------- |
| Opt+, | なし | Ctrl+Opt+Left      | 左半分配置（Rectangle。英数+, も同じ） |
| Opt+. | なし | Ctrl+Opt+Right     | 右半分配置（Rectangle。英数+. も同じ） |
| Opt+K | なし | Ctrl+Opt+Return    | 最大化（Rectangle）                    |
| Opt+R | なし | Ctrl+Opt+Cmd+R     | Reasonable Size（Raycast）       |
| Opt+J | eisuu_pressed ≠ 1 | Cmd+J | ターミナル/パネル開閉（T3 Code / VSCode 等） |
| Opt+N | なし | （コメントアウト） | Next Display。かな + ; が正。未使用 |

### APP（かなレイヤー）

#### AIエージェント操作・定型文

| 入力 | 条件 | 出力 | 備考 |
| --- | --- | --- | --- |
| Shift+Enter + any | kana_pressed = 1 | 英数 → "yes" → Enter | AIエージェントへの承認・許可送信（最優先評価） |
| Enter + optionalAny | kana_pressed = 1 | 英数 → "continue" → Enter | AIエージェントへの続行送信（IME全角化防止付き） |

#### メディア操作

| 入力                | 条件             | 出力        | 備考         |
| ------------------- | ---------------- | ----------- | ------------ |
| Space + optionalAny | kana_pressed = 1 | Play/Pause  | メディア再生 |
| U + optionalAny     | kana_pressed = 1 | Volume Up   | 音量アップ   |
| I + optionalAny     | kana_pressed = 1 | Volume Down | 音量ダウン   |
| Y + optionalAny     | kana_pressed = 1 | Mute        | ミュート     |

#### アプリ起動

| 入力            | 条件             | 出力                                                                                  | 備考                |
| --------------- | ---------------- | ------------------------------------------------------------------------------------- | ------------------- |
| O + optionalAny | kana_pressed = 1 | Open: Obsidian (トグル)                                                               |                     |
| A + optionalAny | kana_pressed = 1 | Open: Antigravity (トグル)                                                            | AI駆動開発メイン |
| M + optionalAny | kana_pressed = 1 | Open: Ghostty (トグル)                                                                | 最頻出ターミナル（右手最短の一等地） |
| Z + optionalAny | kana_pressed = 1 | Open: zoom.us (トグル)                                                                 | 週次MTG中の行き来用 |
| S + optionalAny | kana_pressed = 1 | Open: Dia + Cmd+3 (常時Slackタブへ)                                                   | Slackタブへジャンプ |
| W + optionalAny | kana_pressed = 1 | Open: Warp (トグル)                                                                   | サブ端末            |
| E + optionalAny | kana_pressed = 1 | Open: Mail (トグル)                                                                   |                     |
| B + optionalAny | kana_pressed = 1 | Open: Google Chrome (トグル)                                                          | 移行用（L推奨）     |
| J + optionalAny | kana_pressed = 1 | Open: T3 Code (トグル)                                                                | メイン作業環境（画面左） |
| L + optionalAny | kana_pressed = 1 | Open: Google Chrome (トグル)                                                          | メインブラウザ（画面右） |
| N + optionalAny | kana_pressed = 1 | Open: Dia / Cmd+2 (アクティブ時)                                                      | 思考ハブ (Tab 2)    |
| V + optionalAny | kana_pressed = 1 | Open: Cursor (トグル)                                                                 | IDE代表枠（旧VSCode枠） |
| F + optionalAny | kana_pressed = 1 | Open: Finder (トグル)                                                                 |                     |
| G + optionalAny | kana_pressed = 1 | Open: Grok Bot (トグル)                                                                | Grok デスクトップクライアント |
| T + optionalAny | kana_pressed = 1 | Open: T3 Code (トグル)                                                                 | AIエージェント統御盤 |
| P + optionalAny | kana_pressed = 1 | Open: Microsoft PowerPoint (サイクル)                                                 | 起動中は Cmd+[     |
| C + optionalAny | kana_pressed = 1 | Open: Dia + Cmd+4 (常時Calendarタブへ)                                                | Calendarタブへジャンプ |
| 8 + optionalAny | kana_pressed = 1 | Open: Dia + Cmd+5 (常時Musicタブへ)                                                   | YouTube Musicタブへジャンプ |

### AZIK（日本語入力）

| ルール                                         | 入力      | 条件                       | 出力    | 備考 |
| ---------------------------------------------- | --------- | -------------------------- | ------- | ---- |
| 【AZIK】セミコロンで促音(っ)、コロンで長音(ー) | quote     | Input Source language = ja | hyphen  | 長音 |
<!-- | 【AZIK】セミコロンで促音(っ)、コロンで長音(ー) | semicolon | Input Source language = ja | x, t, u | 促音（Google日本語入力競合のため無効化中） | -->
