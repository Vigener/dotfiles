#Requires AutoHotkey v2.0

; ==============================================================================
; ⚙️ 環境設定・アプリパス定義
;    環境に応じてパスを変更してください。
;    パスに環境変数（%USERPROFILE% / %LocalAppData% / %AppData% / %ProgramFiles%）
;    を使用できます。
; ==============================================================================

; --- メインブラウザ設定 ---
; ThinkPad / Windows: Chrome 優先。Mac Karabiner は launcher.ts の MAIN_BROWSER (Dia/Zen) を参照。
global FALLBACK_BROWSER_EXE := "msedge.exe"
global FALLBACK_BROWSER_PATH := "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
global MAIN_BROWSER_EXE := "chrome.exe"
global MAIN_BROWSER_PATH := "C:\Program Files\Google\Chrome\Application\chrome.exe"
if !FileExist(MAIN_BROWSER_PATH)
    MAIN_BROWSER_PATH := "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
if !FileExist(MAIN_BROWSER_PATH)
    MAIN_BROWSER_PATH := EnvGet("LocalAppData") . "\Google\Chrome\Application\chrome.exe"
if !FileExist(MAIN_BROWSER_PATH) {
    MAIN_BROWSER_EXE := FALLBACK_BROWSER_EXE
    MAIN_BROWSER_PATH := FALLBACK_BROWSER_PATH
}

; ブラウザのタブ番号 (Mac版 Karabiner と同一)
global BROWSER_HUB_TAB := "2"       ; 変換 + N: 思考ハブ (Zen Tab 2)
global BROWSER_SLACK_TAB := "3"     ; 変換 + S: Slackタブ
global BROWSER_CALENDAR_TAB := "4"  ; 変換 + C: カレンダータブ
global BROWSER_MUSIC_TAB := "5"     ; 変換 + 8: YouTube Musicタブ

; --- アプリパス探索ヘルパー ---
FindAppPath(candidates, defaultPath) {
    for path in candidates {
        if (path != "" && FileExist(path))
            return path
    }
    return defaultPath
}

; T3 Code パス解決
global T3_CODE_PATH := FindAppPath([
    EnvGet("LocalAppData") . "\Programs\t3-code\T3 Code.exe",
    EnvGet("LocalAppData") . "\Programs\T3 Code\T3 Code.exe",
    EnvGet("LocalAppData") . "\t3-code\T3 Code.exe",
    EnvGet("ProgramFiles") . "\T3 Code\T3 Code.exe",
    EnvGet("ProgramFiles(x86)") . "\T3 Code\T3 Code.exe"
], EnvGet("LocalAppData") . "\Programs\t3-code\T3 Code.exe")
global T3_CODE_EXE := "T3 Code.exe|t3code.exe"

; Grok Bot パス解決
global GROK_BOT_PATH := FindAppPath([
    EnvGet("LocalAppData") . "\Programs\Grok\Grok.exe",
    EnvGet("LocalAppData") . "\Programs\Grok Bot\Grok Bot.exe",
    EnvGet("LocalAppData") . "\Programs\grok-bot\Grok Bot.exe",
    EnvGet("LocalAppData") . "\Programs\Sand\Sand.exe",
    EnvGet("ProgramFiles") . "\Grok\Grok.exe",
    EnvGet("ProgramFiles") . "\Grok Bot\Grok Bot.exe"
], EnvGet("LocalAppData") . "\Programs\Grok\Grok.exe")
global GROK_BOT_EXE := "Grok.exe|Grok Bot.exe|Sand.exe"

; --- アプリケーション パス・実行ファイル一覧 ---
; ※ APP_REGISTRY にアプリ名 -> [exeName, defaultPath] を登録
global APP_REGISTRY := Map(
    ; ブラウザ
    "Zen", ["zen.exe", EnvGet("LocalAppData") . "\zen\zen.exe"],
    "Chrome", [MAIN_BROWSER_EXE, MAIN_BROWSER_PATH],
    "Edge", ["msedge.exe", "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"],
    "Vivaldi", ["vivaldi.exe", EnvGet("LocalAppData") . "\Vivaldi\Application\vivaldi.exe"],

    ; 開発ツール・エディタ
    "T3Code", [T3_CODE_EXE, T3_CODE_PATH],
    "GrokBot", [GROK_BOT_EXE, GROK_BOT_PATH],
    "Cursor", ["Cursor.exe", EnvGet("LocalAppData") . "\Programs\Cursor\Cursor.exe"],
    "VSCode", ["Code.exe", EnvGet("LocalAppData") . "\Programs\Microsoft VS Code\Code.exe"],
    "Zed", ["zed.exe", EnvGet("LocalAppData") . "\Programs\Zed\zed.exe"],
    "Antigravity", ["antigravity.exe", EnvGet("LocalAppData") . "\Programs\antigravity\antigravity.exe"],
    "Obsidian", ["Obsidian.exe", EnvGet("LocalAppData") . "\Programs\obsidian\Obsidian.exe"],

    ; ターミナル
    "Warp", ["warp.exe", EnvGet("LocalAppData") . "\Programs\Warp\Warp.exe"],
    "Alacritty", ["alacritty.exe", "C:\Program Files\Alacritty\alacritty.exe"],
    "Ghostty", ["ghostty.exe", EnvGet("LocalAppData") . "\Programs\Ghostty\ghostty.exe"],
    "WindowsTerminal", ["WindowsTerminal.exe", "wt.exe"],

    ; コミュニケーション
    "Slack", ["slack.exe", EnvGet("LocalAppData") . "\slack\slack.exe"],
    "Discord", ["Discord.exe", EnvGet("LocalAppData") . "\Discord\Update.exe --processStart Discord.exe"],
    "LINE", ["LINE.exe", EnvGet("LocalAppData") . "\LINE\bin\LineLauncher.exe"],

    ; ドキュメント・オフィス
    "PowerPoint", ["POWERPNT.EXE", "C:\Program Files\Microsoft Office\root\Office16\POWERPNT.EXE"]
)

; --- YouTube Music バックグラウンド制御 ---
global PS_SCRIPT_PATH := A_ScriptDir . "\scripts\youtube_music_play.ps1"
global YTM_PLAYLIST_BGM := "https://music.youtube.com/playlist?list=PLWdDkHo0RZF-yhc1r2H_yOP1kzyJW_8Yn"
global YTM_PLAYLIST_FAV := "https://music.youtube.com/playlist?list=LRYR7OqEbKZk6dgay2HgI_j6OyS8rCW9-rRzl"
