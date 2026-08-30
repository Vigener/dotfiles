#Requires AutoHotkey v2.0

; ==============================================================================
; ⚙️ 環境設定・アプリパス定義
;    環境に応じてパスを変更してください。
;    パスに環境変数（%USERPROFILE% / %LocalAppData% / %AppData% / %ProgramFiles%）
;    を使用できます。
; ==============================================================================

; --- メインブラウザ設定 ---
; 使用するメインブラウザ: "msedge.exe", "chrome.exe", "zen.exe", "dia.exe" など
global MAIN_BROWSER_EXE := "zen.exe"
global MAIN_BROWSER_PATH := EnvGet("LocalAppData") . "\zen\zen.exe"
; フォールバック（見つからない場合のブラウザ）
global FALLBACK_BROWSER_EXE := "msedge.exe"
global FALLBACK_BROWSER_PATH := "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

; ブラウザのタブ番号 (Mac版 Karabiner と同一)
global BROWSER_HUB_TAB := "2"       ; 変換 + N: 思考ハブ (Zen Tab 2)
global BROWSER_SLACK_TAB := "3"     ; 変換 + S: Slackタブ
global BROWSER_CALENDAR_TAB := "4"  ; 変換 + C: カレンダータブ
global BROWSER_MUSIC_TAB := "5"     ; 変換 + 8: YouTube Musicタブ

; --- アプリケーション パス・実行ファイル一覧 ---
; ※ APP_REGISTRY にアプリ名 -> [exeName, defaultPath] を登録
global APP_REGISTRY := Map(
    ; ブラウザ
    "Zen", ["zen.exe", EnvGet("LocalAppData") . "\zen\zen.exe"],
    "Chrome", ["chrome.exe", "C:\Program Files\Google\Chrome\Application\chrome.exe"],
    "Edge", ["msedge.exe", "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"],
    "Vivaldi", ["vivaldi.exe", EnvGet("LocalAppData") . "\Vivaldi\Application\vivaldi.exe"],

    ; 開発ツール・エディタ
    "Cursor", ["Cursor.exe", EnvGet("LocalAppData") . "\Programs\Cursor\Cursor.exe"],
    "VSCode", ["Code.exe", EnvGet("LocalAppData") . "\Programs\Microsoft VS Code\Code.exe"],
    "Zed", ["zed.exe", EnvGet("LocalAppData") . "\Programs\Zed\zed.exe"],
    "Antigravity", ["antigravity.exe", EnvGet("LocalAppData") . "\Programs\antigravity\antigravity.exe"],
    "Obsidian", ["Obsidian.exe", EnvGet("LocalAppData") . "\Programs\obsidian\Obsidian.exe"],

    ; ターミナル
    "Warp", ["warp.exe", EnvGet("LocalAppData") . "\Programs\Warp\Warp.exe"],
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
