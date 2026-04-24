# マッピング表

対象: karabiner/index.ts の現行有効ルール（コメントアウト行は除外）

## APP_VIVALDI

| ルール                                    | 入力            | 条件                                             | 出力           | 備考        |
| ----------------------------------------- | --------------- | ------------------------------------------------ | -------------- | ----------- |
| 【Vivaldi】英数+W で ウィンドウパネル開閉 | w + optionalAny | eisuu_pressed = 1 かつ App = com.vivaldi.Vivaldi | Ctrl+Opt+Cmd+W | Vivaldi専用 |

## APP_WARP

| ルール                                             | 入力       | 条件                       | 出力          | 備考     |
| -------------------------------------------------- | ---------- | -------------------------- | ------------- | -------- |
| 【Warp】Ctrl+Opt+HJKL -> Tmuxプレフィックス + 矢印 | Ctrl+Opt+H | App = dev.warp.Warp-Stable | Ctrl+B, Left  | Tmux操作 |
| 【Warp】Ctrl+Opt+HJKL -> Tmuxプレフィックス + 矢印 | Ctrl+Opt+J | App = dev.warp.Warp-Stable | Ctrl+B, Down  | Tmux操作 |
| 【Warp】Ctrl+Opt+HJKL -> Tmuxプレフィックス + 矢印 | Ctrl+Opt+K | App = dev.warp.Warp-Stable | Ctrl+B, Up    | Tmux操作 |
| 【Warp】Ctrl+Opt+HJKL -> Tmuxプレフィックス + 矢印 | Ctrl+Opt+L | App = dev.warp.Warp-Stable | Ctrl+B, Right | Tmux操作 |

## SYS

| ルール                                                | 入力                         | 条件 | 出力                                                              | 備考               |
| ----------------------------------------------------- | ---------------------------- | ---- | ----------------------------------------------------------------- | ------------------ |
| 【SYS】英数/かなキーをモディファイア化                | CapsLock + optionalAny       | なし | Left Option                                                       | CapsLockをOption化 |
| 【SYS】英数/かなキーをモディファイア化                | japanese_eisuu + optionalAny | なし | 変数 eisuu_pressed=1（押下中）, keyupで0, 単押しで japanese_eisuu | 英数レイヤーフラグ |
| 【SYS】英数/かなキーをモディファイア化                | japanese_kana + optionalAny  | なし | 変数 kana_pressed=1（押下中）, keyupで0, 単押しで japanese_kana   | かなレイヤーフラグ |
| 【SYS】ろキー(international1)をバックスラッシュに変換 | international1               | なし | Option+international3                                             | JIS補正            |

## EDIT（英数レイヤー）

### 例外ルール（修飾付き）

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

### 基本移動・編集

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
| Space + optionalAny | eisuu_pressed = 1 | Cmd+Space                 | Raycast起動 |
| D + optionalAny     | eisuu_pressed = 1 | Cmd+Left, Shift+Cmd+Right | 行選択      |

### Cmdショートカット模倣

| 入力            | 条件              | 出力  | 用途            |
| --------------- | ----------------- | ----- | --------------- |
| Z + optionalAny | eisuu_pressed = 1 | Cmd+Z | Undo            |
| X + optionalAny | eisuu_pressed = 1 | Cmd+X | Cut             |
| C + optionalAny | eisuu_pressed = 1 | Cmd+C | Copy            |
| V + optionalAny | eisuu_pressed = 1 | Cmd+V | Paste           |
| N + optionalAny | eisuu_pressed = 1 | Cmd+N | New             |
| A + optionalAny | eisuu_pressed = 1 | Cmd+A | Select All      |
| E + optionalAny | eisuu_pressed = 1 | Cmd+E | Quick Command等 |
| R + optionalAny | eisuu_pressed = 1 | Cmd+R | Reload          |
| T + optionalAny | eisuu_pressed = 1 | Cmd+T | New Tab         |
| P + optionalAny | eisuu_pressed = 1 | Cmd+P | Print / Palette |
| / + optionalAny | eisuu_pressed = 1 | Cmd+/ | コメント切替    |

### スクリーンショット

| 入力                 | 条件              | 出力             | 用途                               |
| -------------------- | ----------------- | ---------------- | ---------------------------------- |
| Ctrl+Shift+4 (+ any) | eisuu_pressed = 1 | Cmd+Shift+Ctrl+4 | 範囲キャプチャ（クリップボード）   |
| Shift+4 (+ any)      | eisuu_pressed = 1 | Cmd+Shift+4      | 範囲キャプチャ（保存）             |
| Ctrl+Shift+3 (+ any) | eisuu_pressed = 1 | Cmd+Shift+Ctrl+3 | 全画面キャプチャ（クリップボード） |
| Shift+3 (+ any)      | eisuu_pressed = 1 | Cmd+Shift+3      | 全画面キャプチャ（保存）           |

## WINDOW（グローバル）

| ルール                          | 入力        | 条件 | 出力       | 備考           |
| ------------------------------- | ----------- | ---- | ---------- | -------------- |
| 【WINDOW】タブを閉じる (Ctrl+Q) | Ctrl+Q      | なし | Cmd+W      | グローバル     |
| 【WINDOW】Option + HJKL         | Opt+J       | なし | Cmd+H      | Mac非表示      |
| 【WINDOW】Option + HJKL         | Opt+Shift+K | なし | Ctrl+Cmd+F | フルスクリーン |
| 【WINDOW】Option + HJKL         | Opt+H       | なし | Ctrl+Left  | 左スペースへ   |
| 【WINDOW】Option + HJKL         | Opt+L       | なし | Ctrl+Right | 右スペースへ   |

## WINDOW（Raycast Windows Management）

| 入力            | 条件              | 出力               | 想定アクション             |
| --------------- | ----------------- | ------------------ | -------------------------- |
| Opt+,           | なし              | Cmd+Opt+Ctrl+Left  | 左半分配置                 |
| , + optionalAny | eisuu_pressed = 1 | Cmd+Opt+Ctrl+Left  | 左半分配置（英数レイヤー） |
| Opt+.           | なし              | Cmd+Opt+Ctrl+Right | 右半分配置                 |
| . + optionalAny | eisuu_pressed = 1 | Cmd+Opt+Ctrl+Right | 右半分配置（英数レイヤー） |
| Opt+K           | なし              | Cmd+Opt+Ctrl+F     | 最大化                     |
| Opt+N           | なし              | Cmd+Opt+Ctrl+N     | Next Displayへ移動         |

## APP（かなレイヤー）

### メディア操作

| 入力            | 条件             | 出力        | 備考         |
| --------------- | ---------------- | ----------- | ------------ |
| H + optionalAny | kana_pressed = 1 | Play/Pause  | メディア再生 |
| U + optionalAny | kana_pressed = 1 | Volume Up   | 音量アップ   |
| I + optionalAny | kana_pressed = 1 | Volume Down | 音量ダウン   |
| Y + optionalAny | kana_pressed = 1 | Mute        | ミュート     |

### アプリ起動

| 入力            | 条件             | 出力                                                                        | 備考          |
| --------------- | ---------------- | --------------------------------------------------------------------------- | ------------- |
| M + optionalAny | kana_pressed = 1 | Open: Visual Studio Code                                                    |               |
| S + optionalAny | kana_pressed = 1 | Open: Slack                                                                 |               |
| K + optionalAny | kana_pressed = 1 | Open: Karabiner-Elements                                                    |               |
| P + optionalAny | kana_pressed = 1 | Open: Warp                                                                  |               |
| E + optionalAny | kana_pressed = 1 | Open: Mail                                                                  |               |
| B + optionalAny | kana_pressed = 1 | Open: Bitwarden                                                             |               |
| N + optionalAny | kana_pressed = 1 | open '/Users/mikoto/Applications/Vivaldi Apps.localized/Notion.app'         | Vivaldi PWA   |
| C + optionalAny | kana_pressed = 1 | open '/Users/mikoto/Applications/Vivaldi Apps.localized/GoogleCalendar.app' | Vivaldi PWA   |
| G + optionalAny | kana_pressed = 1 | open '/Users/mikoto/Applications/Vivaldi Apps.localized/Gemini.app'         | Vivaldi PWA   |
| V + optionalAny | kana_pressed = 1 | open -b com.vivaldi.Vivaldi                                                 | Bundle ID起動 |

## AZIK（日本語入力）

| ルール                                         | 入力      | 条件                       | 出力    | 備考 |
| ---------------------------------------------- | --------- | -------------------------- | ------- | ---- |
| 【AZIK】セミコロンで促音(っ)、コロンで長音(ー) | quote     | Input Source language = ja | hyphen  | 長音 |
| 【AZIK】セミコロンで促音(っ)、コロンで長音(ー) | semicolon | Input Source language = ja | x, t, u | 促音 |
