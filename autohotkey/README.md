# AutoHotkey 設定 (Mac / Karabiner-Elements 完全互換)

## 概要

Mac (Karabiner-Elements) と Windows (AutoHotkey v2) で**まったく同じ操作感・キーバインド**を実現するための構成です。

- **無変換キー (`vk1D`) ＝ Macの「英数キー」**
  - **長押し/同時押し**: カーソル移動 (HJKL)、単語移動、行頭/行末、Cmdショートカット模倣 (Ctrl+Z/C/V/W/T等)、1行選択、スクショ
  - **単押し**: IME OFF (英語入力モード)
- **変換キー (`vk1C`) ＝ Macの「かなキー」**
  - **長押し/同時押し**: アプリ起動 (トグル式)、ブラウザタブジャンプ、仮想デスクトップ、ウィンドウ分割、メディア操作
  - **単押し**: IME ON (日本語入力モード)

---

## 🗺 アーキテクチャ

`dotfiles/karabiner/rules/` と完全にパラレルな設計になっています。

| ファイル | 役割 | Karabiner対応 |
|---|---|---|
| `main.ahk` | エントリーポイント（各モジュールのインクルード、リロード等） | `index.ts` |
| `config.ahk` | アプリケーションパス・ブラウザタブ設定・環境依存設定 | `launcher.ts` 定数部 |
| `lib/ime.ahk` | Windows IME 制御関数 (`IME_GET`, `IME_SET`, `IME_IsON`) | - |
| `lib/window_utils.ahk` | アプリトグル起動・前面化・キー送信ヘルパー | `launcher.ts` ヘルパー |
| `lib/bracket.ahk` | 選択文字列の括弧囲みヘルパー (`WrapBracket`) | - |
| `rules/sys.ahk` | 無変換/変換キーのモディファイア化、単押しIME、JIS配列補正 | `sys.ts` |
| `rules/edit.ahk` | 無変換レイヤー (HJKL移動、編集、Cmd模倣、行選択、スクショ) | `edit.ts` |
| `rules/window.ahk` | 変換レイヤー (仮想デスクトップ、ウィンドウ配置、タスク切替Vimモード) | `window.ts` |
| `rules/launcher.ahk` | 変換レイヤー (アプリ起動トグル、メディアキー、YouTube Music) | `launcher.ts` |
| `rules/azik.ahk` | 日本語入力時カスタム (コロンで長音「ー」など) | `azik.ts` |
| `rules/hotstrings.ahk` | 短縮入力 (メールアドレス、電話番号、日付・時刻など) | - |
| `scripts/youtube_music_play.ps1` | YouTube Music バックグラウンド再生制御 (CDP) | - |

---

## 🎯 マッピング早見表

### 1. SYS（コア・モディファイア & IME）

| 入力 | 条件 / 操作 | 出力 / 動作 | 備考 |
|---|---|---|---|
| **無変換 (vk1D)** | 単押し (Tap) | IME OFF (英語入力) | Macの英数キー単押しと同等 |
| **無変換 (vk1D)** | 押下中 + 他キー | EDIT レイヤー発火 | Macの英数レイヤーと同等 |
| **変換 (vk1C)** | 単押し (Tap) | IME ON (日本語入力) | Macのかなキー単押しと同等 |
| **変換 (vk1C)** | 押下中 + 他キー | WINDOW / APP レイヤー発火 | Macのかなレイヤーと同等 |
| **ろキー (sc073)** | 単押し | `\` (バックスラッシュ) | JIS配列補正 |
| **Shift + ろ** | 同時押し | `_` (アンダースコア) | そのまま通す |
| **Ctrl + BackSpace** | 任意 | 日本語中: `Ctrl+Z` (Undo)<br>英語中: `Ctrl+BackSpace` (単語削除) | 未確定文字の即時クリア |
| **Ctrl + Delete** | 任意 | IME トグル (ON ↔ OFF) | 直感的なIME切替 |

---

### 2. EDIT（無変換レイヤー: カーソル移動・編集・Cmd模倣）

#### 基本移動・スクロール
| 入力 (無変換 + ) | 出力 | Mac対応 (英数 + ) | 用途 |
|---|---|---|---|
| **H / J / K / L** | `←` / `↓` / `↑` / `→` | Left / Down / Up / Right | 基本カーソル移動 |
| **Ctrl + H / L** | `Ctrl + ←` / `Ctrl + →` | Opt + Left / Right | 単語単位で左右移動 |
| **Ctrl + J / K** | `↓ x5` / `↑ x5` | Down x5 / Up x5 | 高速スクロール (5行) |
| **Alt + H / J / K / L** | `Alt + ←` / `Alt + ↓` / `Alt + ↑` / `Alt + →` | Opt + 矢印 | 行/段落ジャンプ |
| **S / F** | `Home` / `End` | Cmd + Left / Right | 行頭 / 行末へジャンプ |
| **Ctrl + S / F** | `Ctrl + Home` / `Ctrl + End` | Cmd + Up / Down | ドキュメント文頭 / 文末へ |

#### 編集・削除
| 入力 (無変換 + ) | 出力 | Mac対応 (英数 + ) | 用途 |
|---|---|---|---|
| **O** | `BackSpace` | BackSpace | 1文字削除（カーソル左） |
| **Ctrl + O** | `Ctrl + BackSpace` | Opt + BackSpace | 1単語削除（カーソル左） |
| **@ (vkC0)** | `Delete` | Forward Delete | 1文字削除（カーソル右） |
| **Ctrl + @** | `Ctrl + Delete` | Opt + Forward Delete | 1単語削除（カーソル右） |
| **Q** | `Escape` | Escape | ESC |
| **; (vkBB)** | `Enter` | Enter | Enter（ホームポジション維持） |
| **Shift + Enter** | `Ctrl + Shift + Enter` | Cmd + Shift + Enter | 送信・確定（チャット等） |
| **Enter (単体)** | `End` → `Enter` | - | 次の行へ改行挿入 |
| **Ctrl + Enter** | `Up` → `End` → `Enter` | - | 前の行へ改行挿入 |
| **Space** | `Alt + Space` / `Win + S` | Cmd + Space | ランチャー / 検索 |
| **D** | `Home` → `Shift + End` | Cmd+Left -> Shift+Cmd+Right | **1行選択** |
| **R** | `Shift + Ctrl + →` | Shift + Opt + Right | 単語選択 |

#### Cmdショートカット模倣 (MacのCmdをWindowsのCtrlに翻訳)
| 入力 (無変換 + ) | 出力 | 用途 |
|---|---|---|
| **Z / Y** | `Ctrl + Z` / `Ctrl + Y` | 元に戻す (Undo) / やり直し (Redo) |
| **X / C / V** | `Ctrl + X` / `Ctrl + C` / `Ctrl + V` | 切り取り / コピー / 貼り付け |
| **A / N** | `Ctrl + A` / `Ctrl + N` | 全て選択 / 新規作成 |
| **W** | `Ctrl + W` | タブ / ウィンドウを閉じる |
| **T** | `Ctrl + T` (Ctrl併用で `Ctrl + Shift + T`) | 新規タブ / 閉じたタブを復元 |
| **P** | `Ctrl + P` | コマンドパレット / 印刷 |
| **B** | `Ctrl + B` (Ctrl併用で `Ctrl + Alt + B`) | プライマリ / セカンダリ サイドバー開閉 |
| **U** | `Ctrl + U` | 下線 / アクション |
| **G / R / E** | `Ctrl + G` / `Ctrl + R` / `Ctrl + E` | 次を検索 / リロード / Quick Open |
| **[ / ]** | `Alt + ←` / `Alt + →` | 戻る (Back) / 進む (Forward) |
| **/** | `Ctrl + /` | コメントアウト切替 |

#### スクリーンショット & herdr
| 入力 (無変換 + ) | 出力 | 用途 |
|---|---|---|
| **Shift + 4** / **Ctrl + Shift + 4** | `Win + Shift + S` | 範囲切り取り (Snipping Tool) |
| **Shift + 3** / **Ctrl + Shift + 3** | `PrintScreen` | 全画面キャプチャ |
| **1 〜 9** | `Ctrl + Alt + 1..9` | herdr `focus_agent` / ペイン直フォーカス |
| **8 / [** | 括弧囲み | 選択テキストを `()` や `[]` で囲む |

---

### 3. WINDOW（変換レイヤー: 仮想デスクトップ・ウィンドウ操作）

| 入力 (変換 + ) | 出力 | Mac対応 (かな + ) | 用途 |
|---|---|---|---|
| **H / L** | `Win + Ctrl + ←` / `→` | Ctrl + Left / Right | 仮想デスクトップ移動 (Spaces) |
| **J** | `Win + ↓` / `WinMinimize` | Cmd + H | 最小化 / 隠す |
| **K** | `Win + ↑` / `WinMaximize` | Ctrl + Cmd + F | 最大化 / フルスクリーン |
| **, (comma)** | `Win + ←` | Cmd+Opt+Ctrl+Left | ウィンドウ左半分スナップ |
| **. (period)** | `Win + →` | Cmd+Opt+Ctrl+Right | ウィンドウ右半分スナップ |
| **/ (slash)** | `Win + ↑` | Cmd+Opt+Ctrl+F | 最大化 |
| **; (semicolon)** | `Win + Tab` | Ctrl + Up | タスクビュー (Mission Control) |
| **ろ (sc073)** | `Win + Shift + →` | Cmd+Opt+Ctrl+N | 次のディスプレイへウィンドウ移動 |
| **Tab** | `Alt + Ctrl + Tab` | Cmd+Opt+Tab | **固定タスク切り替え** (Vimモード起動) |

#### 🪟 タスク切り替え中の Vim 風操作 (変換+Tab 後)
- `H` / `J` / `K` / `L`: ウィンドウ選択移動 (← ↓ ↑ →)
- `Enter` / `Space`: ウィンドウ決定・フォーカス
- `Escape`: キャンセル

---

### 4. APP（変換レイヤー: アプリ起動 & メディア操作）

すべて**トグル動作**（最前面なら最小化/隠す、非アクティブなら前面化/起動）です。

| 入力 (変換 + ) | 起動 / 対象アプリ | 動作仕様 |
|---|---|---|
| **Space** | メディア | 再生 / 一時停止 (`Media_Play_Pause`) |
| **U / I / Y** | 音量 | 音量アップ / 音量ダウン / ミュート |
| **O** | **Obsidian** | トグル起動 |
| **A** | **Antigravity** | AIエディタ / ターミナル トグル |
| **M** | **Cursor** | メインエディタ トグル |
| **V** | **Visual Studio Code** | トグル起動 |
| **Z** | **Zed** | トグル起動 |
| **W / T** | **Warp** / Windows Terminal | ターミナル トグル |
| **E** | **Edge** / Mail | ブラウザ / メール トグル |
| **B** | **Google Chrome** | トグル起動 |
| **N** | **Zen Browser** (メインブラウザ) | 最前面時は **思考ハブ (タブ2: Ctrl+2)** へジャンプ |
| **S** | **Slack** | メインブラウザ起動 → **Slack (タブ3: Ctrl+3)** へジャンプ |
| **C** | **Calendar** | メインブラウザ起動 → **カレンダー (タブ4: Ctrl+4)** へジャンプ |
| **8** | **YouTube Music** | メインブラウザ起動 → **Music (タブ5: Ctrl+5)** へジャンプ |
| **F** | **エクスプローラー** (Finder) | トグル起動 (`Win + E`) |
| **G** | **Ghostty** | トグル起動 |
| **P** | **Microsoft PowerPoint** | トグル起動 |
| **L** | **LINE** | トグル起動 (※18:00〜翌08:00のみ許可) |

---

### 5. AZIK & 短縮入力 (Hotstrings)

- **AZIK**: 日本語入力中、JISのコロン (`:`) を押すと長音記号「`ー`」が自動入力されます。
- **短縮入力**:
  - `m@@` / `m//` / `v;;` → `vgnrieee@gmail.com`
  - `s;;` / `s--` / `s@@` / `m@s` / `m/u` → `s2310970@u.tsukuba.ac.jp`
  - `0;;` / `0--` / `0@@` / `t@@` → `08021311283`
  - `2;;` → `202310970`
  - `d//` → `2026/08/30` (当日日付: yyyy/MM/dd)
  - `d--` → `2026-08-30` (当日日付: yyyy-MM-dd)
  - `t,,` → `18:05` (現在時刻: HH:mm)

---

## 🛠 スクリプト管理ショートカット

- **無変換 + 0**: スクリプトを即座にリロード（設定変更を即時反映）
- **無変換 + 9**: スクリプトをエディタで開く

---

# 🚀 Windows セットアップ手順ガイド

Windows マシンにこの設定を導入する手順です。

### STEP 1: AutoHotkey v2 のインストール

PowerShell (管理者権限) を開き、以下のコマンドを実行します。

```powershell
winget install AutoHotkey.AutoHotkey
```

> **手動インストールの場合**: [AutoHotkey 公式サイト](https://www.autohotkey.com/) から **v2 (Current Version)** をダウンロードしてインストールします。

---

### STEP 2: ChangeKey で CapsLock を Ctrl に変更 (推奨) & キー配列カスタマイズ

Karabiner の `sys.ts` (CapsLock Option化) と同様に、Windows では CapsLock を Ctrl に変更しておくと最強の操作感になります。

1. [窓の杜 - Change Key](https://forest.watch.impress.co.jp/library/software/changekey/) からダウンロード・展開。
2. `ChgKey.exe` を**管理者として実行**。
3. 画面上の `CapsLock` キーをクリックし、変更先に `Ctrl (左)` を選択。
4. メニューの「登録」→「現在の設定を登録」をクリックし、PC を再起動（またはサインアウト）。

> 💡 **US配列キーボードを使っている場合**:
> US配列には物理的な「無変換」「変換」キーがありませんが、ChangeKey で以下のように割り当てることで、Macの英数/かなキーと完全に同じ物理位置・挙動にできます。
> - `Left Alt` → **無変換** (`0x007B`)
> - `Right Alt` → **変換** (`0x0079`)
>
> ※ ChangeKey は Windows レジストリ（Scancode Map）レベルでキーを変更するため、AutoHotkey も自動的に `vk1D`（無変換）/ `vk1C`（変換）として認識します。

---

### STEP 3: IME（日本語入力）側の確実な切替設定 (強く推奨)

AutoHotkey 単体でも IME を制御（`IMM32` API）していますが、Windows 11 や Chromium 系アプリ（Chrome, Slack, VSCode, Obsidian 等）での取りこぼしや遅延を完全にゼロにするため、**IME 側でも無変換＝OFF、変換＝ON** を設定することを強く推奨します。

#### A. Microsoft IME (Windows 標準) の場合
1. `Win + I` で Windows の「設定」を開く。
2. 「時刻と言語」→「言語と地域」を開く。
3. 「日本語」の右にある `...` をクリックし、「言語のオプション」を選択。
4. ページ下部の「Microsoft IME」の右にある `...` をクリックし、「キーとタッチのカスタマイズ」を開く。
5. キーの割り当てを「オン」にし、以下のように設定：
   - **無変換キー**: `IME-オフ`
   - **変換キー**: `IME-オン`

#### B. Google 日本語入力の場合
1. タスクバーの IME アイコンを右クリックし、「プロパティ」を開く。
2. 「一般」タブの「キー設定の選択」にある「編集...」をクリック。
3. 「コマンド」でソートし、以下のエントリを追加・変更：
   - 入力文字なし / 変換前入力中 等の状態で:
     - `Muhenkan` (無変換) → **IME を無効化**
     - `Henkan` (変換) → **ひらがなを入力** (または IME を有効化)

---

### STEP 4: dotfiles の配置

Windows 側の任意の場所（例: `C:\Users\<ユーザー名>\dotfiles\autohotkey`）に配置します。

```powershell
# Git で dotfiles を clone している場合
cd ~
git clone https://github.com/Vigener/dotfiles.git
```

---

### STEP 5: スタートアップへの登録 (PC起動時に自動実行)

PC 起動時に自動で `main.ahk` が起動するように登録します。

1. `Win + R` を押し、`shell:startup` と入力して Enter（スタートアップフォルダが開きます）。
2. `dotfiles\autohotkey\main.ahk` の**ショートカットを作成**。
3. 作成したショートカットをスタートアップフォルダに配置します。

> **コマンド一発で登録する場合 (PowerShell)**:
> ```powershell
> $WshShell = New-Object -comObject WScript.Shell
> $Shortcut = $WshShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\AutoHotkey_dotfiles.lnk")
> $Shortcut.TargetPath = "$HOME\dotfiles\autohotkey\main.ahk"
> $Shortcut.WorkingDirectory = "$HOME\dotfiles\autohotkey"
> $Shortcut.Save()
> ```

---

### STEP 6: 推奨コンパニオンツール (PowerToys)

Mac の Raycast 相当の機能（ランチャー・画面分割）をフル活用するため、**PowerToys** の導入を推奨します。

```powershell
winget install Microsoft.PowerToys
```

- **PowerToys Run**: `Alt + Space` で爆速アプリ検索・計算機・ファイル検索が起動可能になります（無変換 + Space で呼び出せます）。
- **FancyZones**: `Win + Shift + D` などで画面グリッド分割を高度にカスタマイズできます。

---

### 🔧 トラブルシューティング & Tips

1. **管理者権限で動いているアプリ（タスクマネージャー等）上でキーが効かない場合**:
   - `main.ahk` のショートカットのプロパティで「管理者として実行」にチェックを入れるか、タスクスケジューラで「最上位の特権で実行」として登録してください。
2. **アプリのパスが自分の環境と異なる場合**:
   - `config.ahk` を開き、該当アプリのパスや `MAIN_BROWSER_EXE` を変更し、`無変換 + 0` でリロードしてください。
3. **無変換・変換を押したときに文字入力が誤作動する場合**:
   - 上記の「STEP 3: IME（日本語入力）側の確実な切替設定」を適用してください。OSネイティブで処理されるため完全に安定します。
