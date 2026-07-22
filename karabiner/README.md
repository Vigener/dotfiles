# Karabiner-Elements 設定

## 主な割り当ての意図

- 英数キーをモディファイア化し、英数レイヤーでカーソル移動や編集操作を行えるようにする
- かなキーをモディファイア化し、かなレイヤーでメディア操作やアプリ起動を行えるようにする

## 検討中の点

- MacBook Air内臓キーボードと、HHKB Studioの`Cmd`, `Opt`が逆問題を解決する。
  - おそらく、内蔵キーボードに合わせる方が自然な気がする。
  - ただし、デバイス毎に設定を分けることで、両立できると考えられるため、実装検討中。

## メモ（キー割り当ての決定経緯など）

- **YouTube Music（ブラウザ5番目のタブ）を「かな＋8」にした理由**
  - 音量系操作（U:アップ、I:ダウン、Y:ミュート）との近さと、音楽という絶対的サブタスク（バックグラウンド用）であることから、できればノールックで瞬間的に押したい作業であるため。
  - ノー・ルックで押しやすいキーを考慮すると、右手の中指と薬指を自然と伸ばした先にある「8」と「0」が候補として残った。その上で、UとIの上にある「8」を採用した。
  - 今後「かなキー＋数字」の割り当てが増える場合、基本的には「メインブラウザの先頭から何番目のタブにあるか」に数字キーを関連付けるのが無難。しかし、右手で押しづらい「1〜5」については、アルファベットキーに割り当てる方針とする（現に1〜4番目のタブはGemini, Hub, Slack, Calendarとしてアルファベットに割り当て済みであり、残り1つ程度であればアルファベットで賄えるはずであるため）。

## マッピング表

対象: karabiner/index.ts の現行有効ルール（コメントアウト行は除外）

### APP_VIVALDI

| ルール                                        | 入力            | 条件                                             | 出力           | 備考        |
| --------------------------------------------- | --------------- | ------------------------------------------------ | -------------- | ----------- |
| 【Vivaldi】英数+W/G で 専用ショートカット起動 | w + optionalAny | eisuu_pressed = 1 かつ App = com.vivaldi.Vivaldi | Ctrl+Opt+Cmd+W | Vivaldi専用 |
| 【Vivaldi】英数+W/G で 専用ショートカット起動 | g + optionalAny | eisuu_pressed = 1 かつ App = com.vivaldi.Vivaldi | Ctrl+Opt+Cmd+G | Vivaldi専用 |

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

#### 基本移動・編集

| 入力                | 条件              | 出力                      | 意図        |
| ------------------- | ----------------- | ------------------------- | ----------- |
| H + optionalAny     | eisuu_pressed = 1 | Left                      | カーソル左  |
| J + optionalAny     | eisuu_pressed = 1 | Down                      | カーソル下  |
| K + optionalAny     | eisuu_pressed = 1 | Up                        | カーソル上  |
| L + optionalAny     | eisuu_pressed = 1 | Right                     | カーソル右  |
| S + optionalAny     | eisuu_pressed = 1 | Cmd+Left                  | 行頭        |
| F + optionalAny     | eisuu_pressed = 1 | Cmd+Right                 | 行末        |
| O + optionalAny     | eisuu_pressed = 1 | Backspace                 | 1文字削除   |
| [ + optionalAny     | eisuu_pressed = 1 | Delete Forward            | 前方削除    |
| Q + optionalAny     | eisuu_pressed = 1 | Escape                    | ESC         |
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
| / + optionalAny | eisuu_pressed = 1 | Cmd+/ | コメント切替    |

#### スクリーンショット

| 入力                 | 条件              | 出力             | 用途                               |
| -------------------- | ----------------- | ---------------- | ---------------------------------- |
| Ctrl+Shift+4 (+ any) | eisuu_pressed = 1 | Cmd+Shift+Ctrl+4 | 範囲キャプチャ（クリップボード）   |
| Shift+4 (+ any)      | eisuu_pressed = 1 | Cmd+Shift+4      | 範囲キャプチャ（保存）             |
| Ctrl+Shift+3 (+ any) | eisuu_pressed = 1 | Cmd+Shift+Ctrl+3 | 全画面キャプチャ（クリップボード） |
| Shift+3 (+ any)      | eisuu_pressed = 1 | Cmd+Shift+3      | 全画面キャプチャ（保存）           |



### WINDOW（かなレイヤー）

#### Spaces・ウィンドウ状態操作

| 入力            | 条件             | 出力       | 想定アクション |
| --------------- | ---------------- | ---------- | -------------- |
| H + optionalAny | kana_pressed = 1 | Ctrl+Left  | 左のスペース   |
| L + optionalAny | kana_pressed = 1 | Ctrl+Right | 右のスペース   |
| J + optionalAny | kana_pressed = 1 | Cmd+H      | 隠す           |
| K + optionalAny | kana_pressed = 1 | Ctrl+Cmd+F | フルスクリーン |

#### Raycast Windows Management (かなレイヤー)

| 入力                  | 条件             | 出力               | 想定アクション     |
| --------------------- | ---------------- | ------------------ | ------------------ |
| , + optionalAny       | kana_pressed = 1 | Cmd+Opt+Ctrl+Left  | 左半分配置         |
| . + optionalAny       | kana_pressed = 1 | Cmd+Opt+Ctrl+Right | 右半分配置         |
| / + optionalAny       | kana_pressed = 1 | Cmd+Opt+Ctrl+F     | ほぼ最大化         |
| Shift+/ + optionalAny | kana_pressed = 1 | Cmd+Ctrl+F         | 完全最大化         |
| ; + optionalAny       | kana_pressed = 1 | Ctrl+Up            | Mission Control    |
| : + optionalAny       | kana_pressed = 1 | Cmd+Opt+Ctrl+R     | Reasonable Size    |
| international1        | kana_pressed = 1 | Cmd+Opt+Ctrl+N     | Next Displayへ移動 |

### WINDOW（Raycast Windows Management - グローバル）

| 入力  | 条件 | 出力               | 想定アクション                   |
| ----- | ---- | ------------------ | -------------------------------- |
| Opt+, | なし | Cmd+Opt+Ctrl+Left  | 左半分配置（グローバル）         |
| Opt+. | なし | Cmd+Opt+Ctrl+Right | 右半分配置（グローバル）         |
| Opt+K | なし | Cmd+Opt+Ctrl+F     | 最大化（グローバル）             |
| Opt+N | なし | Cmd+Opt+Ctrl+N     | Next Displayへ移動（グローバル） |

### APP（かなレイヤー）

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
| A + optionalAny | kana_pressed = 1 | Open: Antigravity (トグル)                                                            |                     |
| M + optionalAny | kana_pressed = 1 | Open: Cursor (トグル)                                                                 | メインエディタ      |
| Z + optionalAny | kana_pressed = 1 | Open: Zed (トグル)                                                                     |                     |
| S + optionalAny | kana_pressed = 1 | Open: Dia + Cmd+3 (常時Slackタブへ)                                                   | Slackタブへジャンプ |
| W + optionalAny | kana_pressed = 1 | Open: Warp (トグル)                                                                   |                     |
| T + optionalAny | kana_pressed = 1 | Open: Warp (トグル)                                                                   |                     |
| E + optionalAny | kana_pressed = 1 | Open: Mail (トグル)                                                                   |                     |
| B + optionalAny | kana_pressed = 1 | Open: Google Chrome (トグル)                                                          |                     |
| N + optionalAny | kana_pressed = 1 | Open: Zen Browser / Cmd+2 (アクティブ時)                                               | 思考ハブ (Tab 2)    |
| V + optionalAny | kana_pressed = 1 | Open: Visual Studio Code (トグル)                                                      |                     |
| F + optionalAny | kana_pressed = 1 | Open: Finder (トグル)                                                                 |                     |
| G + optionalAny | kana_pressed = 1 | Open: Zen Browser + Cmd+1 (常時Geminiタブへ)                                          | Geminiタブへジャンプ |
| P + optionalAny | kana_pressed = 1 | Open: Microsoft PowerPoint (サイクル)                                                 | 起動中は Cmd+[     |
| C + optionalAny | kana_pressed = 1 | Open: Dia + Cmd+4 (常時Calendarタブへ)                                                | Calendarタブへジャンプ |
| 8 + optionalAny | kana_pressed = 1 | Open: Dia + Cmd+5 (常時Musicタブへ)                                                   | YouTube Musicタブへジャンプ |

### AZIK（日本語入力）

| ルール                                         | 入力      | 条件                       | 出力    | 備考 |
| ---------------------------------------------- | --------- | -------------------------- | ------- | ---- |
| 【AZIK】セミコロンで促音(っ)、コロンで長音(ー) | quote     | Input Source language = ja | hyphen  | 長音 |
| 【AZIK】セミコロンで促音(っ)、コロンで長音(ー) | semicolon | Input Source language = ja | x, t, u | 促音 |
