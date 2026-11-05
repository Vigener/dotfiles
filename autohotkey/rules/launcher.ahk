#Requires AutoHotkey v2.0

; ==============================================================================
; [APP] 変換レイヤー (アプリ起動・切り替え・メディア操作)
; - メディア操作: Space (再生/停止), U (音量Up), I (音量Down), Y (ミュート)
; - アプリ起動 (トグル式: 最前面なら最小化、非アクティブなら前面化/起動):
;   O: Obsidian
;   A: Antigravity (AIエディタ/ターミナル)
;   M: Cursor (メインエディタ)
;   Z: Zed
;   S: メインブラウザ -> Slackタブ (Ctrl+3)
;   W: Warp / Windows Terminal
;   E: Edge / Mail
;   B: Google Chrome
;   J: T3 Code (メイン作業環境)
;   T: T3 Code (移行用)
;   G: Grok Bot
;   N: Zen / メインブラウザ (アクティブ時は思考ハブ Ctrl+2 へ)
;   V: Visual Studio Code
;   F: エクスプローラー
;   C: メインブラウザ -> Calendarタブ (Ctrl+4)
;   8: メインブラウザ -> YouTube Musicタブ (Ctrl+5)
;   P: Microsoft PowerPoint
;   L: (window.ahk) 右の仮想デスクトップ — LINE は Karabiner 同様未割り当て
; ==============================================================================

; --- 1. メディア操作 ---
vk1C & Space::Send("{Media_Play_Pause}")
vk1C & u::Send("{Volume_Up}")
vk1C & i::Send("{Volume_Down}")
vk1C & y::Send("{Volume_Mute}")

; --- 2. アプリ起動 (トグル式) ---

; J: T3 Code (メイン作業環境・最頻出)
vk1C & j::LaunchRegisteredApp("T3Code")

; T: T3 Code (Mac Karabiner互換の移行用)
vk1C & t::LaunchRegisteredApp("T3Code")

; G: Grok Bot (Mac Karabiner互換)
vk1C & g::LaunchRegisteredApp("GrokBot")

; B: Google Chrome
vk1C & b::LaunchRegisteredApp("Chrome")

; O: Obsidian
vk1C & o::LaunchRegisteredApp("Obsidian")

; A: Antigravity
vk1C & a::LaunchRegisteredApp("Antigravity")

; M: Cursor
vk1C & m::LaunchRegisteredApp("Cursor")

; Z: Zed
vk1C & z::LaunchRegisteredApp("Zed")

; V: Visual Studio Code
vk1C & v::LaunchRegisteredApp("VSCode")

; W: Warp (または Windows Terminal)
vk1C & w::LaunchRegisteredApp("Warp")

; E: Edge / Mail
vk1C & e::LaunchRegisteredApp("Edge")

; F: エクスプローラー (Finder 相当)
vk1C & f::
{
    if WinExist("ahk_class CabinetWClass") {
        if WinActive("ahk_class CabinetWClass")
            WinMinimize("ahk_class CabinetWClass")
        else
            WinActivate("ahk_class CabinetWClass")
    } else {
        Send("#e")
    }
}

; P: PowerPoint
vk1C & p::LaunchRegisteredApp("PowerPoint")

; --- 3. ブラウザタブ連携起動 (Macの Karabiner と同一仕様) ---

; N: メインブラウザ (アクティブ時は思考ハブタブ Ctrl+2、非アクティブ時は起動/前面化)
vk1C & n::
{
    global MAIN_BROWSER_EXE, MAIN_BROWSER_PATH, BROWSER_HUB_TAB
    ToggleAppOrSendKey(MAIN_BROWSER_EXE, MAIN_BROWSER_PATH, "^" . BROWSER_HUB_TAB)
}

; S: メインブラウザを呼び出して Slackタブ (Ctrl+3) へジャンプ
vk1C & s::
{
    global MAIN_BROWSER_EXE, MAIN_BROWSER_PATH, BROWSER_SLACK_TAB
    ToggleAppWithKey(MAIN_BROWSER_EXE, MAIN_BROWSER_PATH, "^" . BROWSER_SLACK_TAB)
}

; C: メインブラウザを呼び出して Calendarタブ (Ctrl+4) へジャンプ
vk1C & c::
{
    global MAIN_BROWSER_EXE, MAIN_BROWSER_PATH, BROWSER_CALENDAR_TAB
    ToggleAppWithKey(MAIN_BROWSER_EXE, MAIN_BROWSER_PATH, "^" . BROWSER_CALENDAR_TAB)
}

; 8: メインブラウザを呼び出して YouTube Musicタブ (Ctrl+5) へジャンプ
vk1C & 8::
{
    global MAIN_BROWSER_EXE, MAIN_BROWSER_PATH, BROWSER_MUSIC_TAB
    ToggleAppWithKey(MAIN_BROWSER_EXE, MAIN_BROWSER_PATH, "^" . BROWSER_MUSIC_TAB)
}

; L is virtual desktop right (rules/window.ahk). LINE is not on this key (Karabiner: kana+L = Space right).

; --- 4. YouTube Music バックグラウンド制御 (PowerShell連携) ---
RunYTMPlaylist(scriptPath, url, label) {
    if !FileExist(scriptPath) {
        ToolTip("YTM Script not found: " . scriptPath)
        SetTimer(() => ToolTip(), -3000)
        return
    }

    ToolTip("Playing " . label . " playlist...")
    SetTimer(() => ToolTip(), -2000)

    cmd := 'powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "' . scriptPath . '" -PlaylistUrl "' . url . '"'
    Run(cmd, , "Hide")
}

^!q::
{
    global PS_SCRIPT_PATH, YTM_PLAYLIST_BGM
    RunYTMPlaylist(PS_SCRIPT_PATH, YTM_PLAYLIST_BGM, "BGM")
}

^!f::
{
    global PS_SCRIPT_PATH, YTM_PLAYLIST_FAV
    RunYTMPlaylist(PS_SCRIPT_PATH, YTM_PLAYLIST_FAV, "Favorites")
}
