#Requires AutoHotkey v2.0
#SingleInstance Force

; ==============================================================================
; 🚀 dotfiles / AutoHotkey (v2) - Main Entry Point
;    Mac (Karabiner-Elements) と同一の操作感を Windows 上に完全再現する設定
; ==============================================================================

; --- 基本設定 ---
SendMode("Input")
SetWorkingDir(A_ScriptDir)

; --- ライブラリ読み込み ---
#Include "config.ahk"
#Include "lib/ime.ahk"
#Include "lib/window_utils.ahk"
#Include "lib/bracket.ahk"

; --- ルール読み込み ---
; 1. システム・モディファイア (無変換/変換キー、IME連携、JIS補正)
#Include "rules/sys.ahk"

; 2. エディットレイヤー (無変換キー + HJKL/Cmd模倣/編集操作)
#Include "rules/edit.ahk"

; 3. ウィンドウレイヤー (変換キー + 仮想デスクトップ/スナップ/タスク切替)
#Include "rules/window.ahk"

; 4. アプリ・メディアレイヤー (変換キー + アプリトグル/メディアキー)
#Include "rules/launcher.ahk"

; 5. 日本語入力補助 (AZIK/長音記号)
#Include "rules/azik.ahk"

; 6. 短縮入力 (Hotstrings)
#Include "rules/hotstrings.ahk"

; --- スクリプト管理ショートカット ---
; 無変換 + 0 でスクリプトを即時リロード
~vk1D & 0::
{
    ToolTip("Reloading AutoHotkey...")
    Sleep(500)
    Reload()
}

; 無変換 + 9 でスクリプトディレクトリをエディタで開く
~vk1D & 9::
{
    Edit()
}

; --- アイドル時タイマー (無操作時にIMEを自動OFF) ---
SetTimer(IMEreset, 60000)

; 起動完了通知
TraySetIcon("shell32.dll", 44)
A_IconTip := "dotfiles AutoHotkey (Mac-like Keybindings)"
ToolTip("AutoHotkey (Mac-like) Loaded!")
SetTimer(() => ToolTip(), -2000)
