# Karabiner-Elements 設定

## 主な割り当ての意図

- 英数キーをモディファイア化し、英数レイヤーでカーソル移動や編集操作を行えるようにする
- かなキーをモディファイア化し、かなレイヤーでメディア操作やアプリ起動を行えるようにする

## 検討中の点

- 「Zoomのアプリ起動(kana+Z)」と「Finderのアプリ起動(kana+F)」導入
- 「PowerPointのアプリ起動」の導入検討
    - 今現在、Windows時代の習慣で、`kana+P`にWarpが割り当てられているが、以前検討していた、`kana+Enter`にWarpを移動すれば、頭文字の`P`が覚えやすいPowerPointの起動を割り当てられるため、検討中
    - 検討案２: Warpをおとなしく`kana+W`に移動して、`kana+P`をPowerPointに割り当てる
        - w開始のアプリが増えたら、そのときまた考える。
- MacBook Air内臓キーボードと、HHKB Studioの`Cmd`, `Opt`が逆問題を解決する。
    - おそらく、内蔵キーボードに合わせる方が自然な気がする。
    - ただし、それに伴い、Raycastと組み合わせたOptionキー支点のウィンドウ管理ショートカットが打ちづらくなるので、再検討をする。

### Raycast Windows Managementとの組み合わせの検討

- JISキーボードユーザーとしての意見として、まず基本的に、内蔵キーボードに合わせると仮定した場合に、
- [CapsLock, left_option, left_command, 英数, Space, かな, right_command, (right_option), fn]の並びの中で、打ちやすいと感じるのは、[left_command, 英数, Space, かな, right_command]のあたりで、Optionキーはやや遠いと感じる。
- そのため、Optionキーを支点としたウィンドウ管理ショートカットは、未割り当てのものは、英数キーにも同様の機能を与えているが、正直、使えるキーと使えないキーがあるのは、認知負荷が高いので、別のキーに割り当て直すべきだと感じる。
- Optionキーを起点としたウィンドウ管理は、AeroSpaceの名残の部分があると感じており、このAeroSpace用のハイバーキーを別のものにしてしまうというのもありだと思う。
- 今現在考えているのは、今までWindows時代も、一切割り当ててこなかったので、少し押し慣れてないないが、右Commandキーをウィンドウ管理の支点とすることがかなりアリなのではと考えている。
    - 理由としては、アプリ起動がかなキーに紐づいて右手操作であるため、ウィンドウ管理も右手で完結させる方が自然な気がすること。
    - また、Cmdキーを使う際に、僕は、全て左Cmdキーで完結しており、右Cmdキーはあまり使わないため、右Cmdキーをウィンドウ管理の支点にすることは、特に支障がないと感じること。
- 次に、案としてあるのは、かなキーの役割をさらに増やし、かなキーを支点としたウィンドウ管理ショートカットを割り当てること。
    - 具体的には、アルファベットはアプリ起動で使われることが多いため、["," ".", "/", "\"]などを考えている。
        - 左半分配置: `kana+,`
        - 右半分配置: `kana+.`
        - ほぼ最大化: `kana+/`
            - 完全最大化: `kana+shift+/`
        - Next Displayへ移動: `kana+\`
        - 非表示: `kana+right_command`
    - この利点は、アプリ（ウィンドウ）操作が全て、かなキー支点になること。また、ウィンドウ操作が右手で完結すること。
    - 記号は今後も、アプリ起動で使うことはあまりないと感じるため、割り当ての自由度や今後増やしたいウィンドウ操作に対してもある程度は余裕があること。

## マッピング表

対象: karabiner/index.ts の現行有効ルール（コメントアウト行は除外）

### APP_VIVALDI

| ルール                                    | 入力            | 条件                                             | 出力           | 備考        |
| ----------------------------------------- | --------------- | ------------------------------------------------ | -------------- | ----------- |
| 【Vivaldi】英数+W で ウィンドウパネル開閉 | w + optionalAny | eisuu_pressed = 1 かつ App = com.vivaldi.Vivaldi | Ctrl+Opt+Cmd+W | Vivaldi専用 |

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
| Space + optionalAny | eisuu_pressed = 1 | Cmd+Space                 | Raycast起動 |
| D + optionalAny     | eisuu_pressed = 1 | Cmd+Left, Shift+Cmd+Right | 行選択      |

#### Cmdショートカット模倣

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

#### スクリーンショット

| 入力                 | 条件              | 出力             | 用途                               |
| -------------------- | ----------------- | ---------------- | ---------------------------------- |
| Ctrl+Shift+4 (+ any) | eisuu_pressed = 1 | Cmd+Shift+Ctrl+4 | 範囲キャプチャ（クリップボード）   |
| Shift+4 (+ any)      | eisuu_pressed = 1 | Cmd+Shift+4      | 範囲キャプチャ（保存）             |
| Ctrl+Shift+3 (+ any) | eisuu_pressed = 1 | Cmd+Shift+Ctrl+3 | 全画面キャプチャ（クリップボード） |
| Shift+3 (+ any)      | eisuu_pressed = 1 | Cmd+Shift+3      | 全画面キャプチャ（保存）           |

### WINDOW（グローバル）

| ルール                          | 入力        | 条件 | 出力       | 備考           |
| ------------------------------- | ----------- | ---- | ---------- | -------------- |
| 【WINDOW】タブを閉じる (Ctrl+Q) | Ctrl+Q      | なし | Cmd+W      | グローバル     |
| 【WINDOW】Option + HJKL         | Opt+J       | なし | Cmd+H      | Mac非表示      |
| 【WINDOW】Option + HJKL         | Opt+Shift+K | なし | Ctrl+Cmd+F | フルスクリーン |
| 【WINDOW】Option + HJKL         | Opt+H       | なし | Ctrl+Left  | 左スペースへ   |
| 【WINDOW】Option + HJKL         | Opt+L       | なし | Ctrl+Right | 右スペースへ   |

### WINDOW（Raycast Windows Management）

| 入力            | 条件              | 出力               | 想定アクション             |
| --------------- | ----------------- | ------------------ | -------------------------- |
| Opt+,           | なし              | Cmd+Opt+Ctrl+Left  | 左半分配置                 |
| , + optionalAny | eisuu_pressed = 1 | Cmd+Opt+Ctrl+Left  | 左半分配置（英数レイヤー） |
| Opt+.           | なし              | Cmd+Opt+Ctrl+Right | 右半分配置                 |
| . + optionalAny | eisuu_pressed = 1 | Cmd+Opt+Ctrl+Right | 右半分配置（英数レイヤー） |
| Opt+K           | なし              | Cmd+Opt+Ctrl+F     | 最大化                     |
| Opt+N           | なし              | Cmd+Opt+Ctrl+N     | Next Displayへ移動         |

### APP（かなレイヤー）

#### メディア操作

| 入力            | 条件             | 出力        | 備考         |
| --------------- | ---------------- | ----------- | ------------ |
| H + optionalAny | kana_pressed = 1 | Play/Pause  | メディア再生 |
| U + optionalAny | kana_pressed = 1 | Volume Up   | 音量アップ   |
| I + optionalAny | kana_pressed = 1 | Volume Down | 音量ダウン   |
| Y + optionalAny | kana_pressed = 1 | Mute        | ミュート     |

#### アプリ起動

| 入力            | 条件             | 出力                                                                        | 備考          |
| --------------- | ---------------- | --------------------------------------------------------------------------- | ------------- |
| M + optionalAny | kana_pressed = 1 | Open: Visual Studio Code                                                    |               |
| S + optionalAny | kana_pressed = 1 | Open: Slack                                                                 |               |
| K + optionalAny | kana_pressed = 1 | Open: Karabiner-Elements                                                    |               |
| W + optionalAny | kana_pressed = 1 | Open: Warp                                                                  |               |
| E + optionalAny | kana_pressed = 1 | Open: Mail                                                                  |               |
| B + optionalAny | kana_pressed = 1 | Open: Bitwarden                                                             |               |
| F + optionalAny | kana_pressed = 1 | Open: Finder                                                                |               |
| P + optionalAny | kana_pressed = 1 | Open: Microsoft PowerPoint                                                  |               |
| Z + optionalAny | kana_pressed = 1 | Open: zoom.us                                                               |               |
| N + optionalAny | kana_pressed = 1 | open '/Users/mikoto/Applications/Vivaldi Apps.localized/Notion.app'         | Vivaldi PWA   |
| C + optionalAny | kana_pressed = 1 | open '/Users/mikoto/Applications/Vivaldi Apps.localized/GoogleCalendar.app' | Vivaldi PWA   |
| G + optionalAny | kana_pressed = 1 | open '/Users/mikoto/Applications/Vivaldi Apps.localized/Gemini.app'         | Vivaldi PWA   |
| V + optionalAny | kana_pressed = 1 | open -b com.vivaldi.Vivaldi                                                 | Bundle ID起動 |

### AZIK（日本語入力）

| ルール                                         | 入力      | 条件                       | 出力    | 備考 |
| ---------------------------------------------- | --------- | -------------------------- | ------- | ---- |
| 【AZIK】セミコロンで促音(っ)、コロンで長音(ー) | quote     | Input Source language = ja | hyphen  | 長音 |
| 【AZIK】セミコロンで促音(っ)、コロンで長音(ー) | semicolon | Input Source language = ja | x, t, u | 促音 |
