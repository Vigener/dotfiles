#Requires AutoHotkey v2.0

; ==============================================================================
; [EDIT] 無変換レイヤー (Macの英数レイヤーに完全対応)
; - 基本移動: HJKL (左下上右), S/F (行頭/行末)
; - 高速移動: Ctrl+H/L (単語移動), Ctrl+J/K (5行スクロール), Ctrl+S/F (文頭/文末)
; - 削除系:   O (BackSpace), Ctrl+O (単語削除), @ (Delete), Ctrl+@ (次単語削除)
; - 確定・Esc: ; (Enter), Q (Esc), Shift+Enter (Ctrl+Shift+Enter)
; - 行選択:   D (行頭移動 -> 行末まで選択)
; - Cmd模倣:  Z, Y, X, C, V, A, N, W, T, P, B, U, R, G, E, [, ], /
; - スクショ: Shift+4 (範囲切取 Win+Shift+S), Shift+3 (全画面 PrintScreen)
; - herdr:    1..9 (Ctrl+Alt+1..9)
; - 括弧囲み: 8 ("()"), [ ("[]" / "{}")
; ==============================================================================

; --- 1. カーソル移動系 (H, J, K, L) ---
vk1D & h::
{
    if GetKeyState("Ctrl", "P")
        Send("{Blind}^{Left}")
    else if GetKeyState("Alt", "P")
        Send("{Blind}!{Left}")
    else
        Send("{Blind}{Left}")
}

vk1D & l::
{
    if GetKeyState("Ctrl", "P")
        Send("{Blind}^{Right}")
    else if GetKeyState("Alt", "P")
        Send("{Blind}!{Right}")
    else
        Send("{Blind}{Right}")
}

vk1D & j::
{
    if GetKeyState("Ctrl", "P")
        Send("{Blind}{Down 5}")
    else if GetKeyState("Alt", "P")
        Send("{Blind}!{Down}")
    else
        Send("{Blind}{Down}")
}

vk1D & k::
{
    if GetKeyState("Ctrl", "P")
        Send("{Blind}{Up 5}")
    else if GetKeyState("Alt", "P")
        Send("{Blind}!{Up}")
    else
        Send("{Blind}{Up}")
}

; --- 2. 行頭・行末 / 文頭・文末 (S, F) ---
vk1D & s::
{
    if GetKeyState("Ctrl", "P")
        Send("{Blind}^{Home}")
    else
        Send("{Blind}{Home}")
}

vk1D & f::
{
    if GetKeyState("Ctrl", "P")
        Send("{Blind}^{End}")
    else
        Send("{Blind}{End}")
}

; --- 3. 削除系 (O, @) ---
vk1D & o::
{
    if GetKeyState("Ctrl", "P")
        Send("{Blind}^{BackSpace}")
    else
        Send("{Blind}{BackSpace}")
}

; JIS配列の「@」キー (vkC0 / sc01A)
vk1D & vkC0::
{
    if GetKeyState("Ctrl", "P")
        Send("{Blind}^{Delete}")
    else
        Send("{Blind}{Delete}")
}

; --- 4. 確定・キャンセル・特殊キー (Q, ;, Enter, Space) ---
vk1D & q::Send("{Blind}{Escape}")

; セミコロン (vkBB) で Enter
vk1D & vkBB::Send("{Blind}{Enter}")

; 無変換 + Enter (Shift押下で Ctrl+Shift+Enter, Ctrl押下で行挿入)
vk1D & Enter::
{
    if GetKeyState("Shift", "P")
        Send("^+{Enter}")
    else if GetKeyState("Ctrl", "P")
        Send("{Up}{End}{Enter}")
    else
        Send("{End}{Enter}")
}

; Space でランチャー（PowerToys Run または Windows Search）
vk1D & Space::
{
    ; PowerToys Run (!Space) または Windows 検索 (#s)
    Send("!{Space}")
}

; --- 5. 選択・vim風操作 (D, R) ---
; D: 1行選択 (行頭へ移動して行末まで選択)
vk1D & d::
{
    Send("{Home}+{End}")
}

; R: 単語選択 (Shift+Ctrl+Right)
vk1D & r::
{
    if GetKeyState("Ctrl", "P")
        Send("{Blind}^r")
    else
        Send("{Blind}+^{Right}")
}

; --- 6. Cmdショートカット模倣 (MacのCmdをWindowsのCtrlに翻訳) ---
vk1D & z::Send("{Blind}^z")           ; Undo
vk1D & y::Send("{Blind}^y")           ; Redo
vk1D & x::Send("{Blind}^x")           ; Cut
vk1D & c::Send("{Blind}^c")           ; Copy
vk1D & v::Send("{Blind}^v")           ; Paste
vk1D & a::Send("{Blind}^a")           ; Select All
vk1D & n::Send("{Blind}^n")           ; New
vk1D & w::Send("{Blind}^w")           ; Close Tab / Window

vk1D & t::
{
    if GetKeyState("Ctrl", "P")
        Send("^+t")                   ; 閉じたタブを開く (Ctrl+Shift+T)
    else
        Send("{Blind}^t")             ; New Tab
}

vk1D & p::Send("{Blind}^p")           ; Palette / Print

vk1D & b::
{
    if GetKeyState("Ctrl", "P")
        Send("!^b")                   ; セカンダリサイドバー (Ctrl+Alt+B)
    else
        Send("{Blind}^b")             ; サイドバー開閉 (Ctrl+B)
}

vk1D & u::Send("{Blind}^u")           ; Underline / Action
vk1D & g::Send("{Blind}^g")           ; Find Next
vk1D & e::Send("{Blind}^e")           ; Quick Open / Search

; JIS [ (vkDB) -> 戻る (Alt+Left)
vk1D & vkDB::Send("!{Left}")
; JIS ] (vkDD) -> 進む (Alt+Right)
vk1D & vkDD::Send("!{Right}")

; スラッシュ (vkBF) -> コメント切替 (Ctrl+/)
vk1D & vkBF::Send("^/")

; --- 7. スクリーンショット (Mac: Cmd+Shift+3/4) ---
; 無変換 + 4 (ShiftまたはCtrl付き) -> Snipping Tool (Win+Shift+S)
vk1D & 4::
{
    if GetKeyState("Shift", "P") || GetKeyState("Ctrl", "P")
        Send("#+s")
    else
        Send("^!4")
}

; 無変換 + 3 (ShiftまたはCtrl付き) -> 全画面キャプチャ (PrintScreen)
vk1D & 3::
{
    if GetKeyState("Shift", "P") || GetKeyState("Ctrl", "P")
        Send("{PrintScreen}")
    else
        Send("^!3")
}

; --- 8. herdr focus_agent (無変換 + 1..9 -> Ctrl+Alt+1..9) ---
vk1D & 1::Send("^!1")
vk1D & 2::Send("^!2")
vk1D & 5::Send("^!5")
vk1D & 6::Send("^!6")
vk1D & 7::Send("^!7")
vk1D & 9::Send("^!9")

; --- 9. 括弧囲み (8, [) ---
vk1D & 8::WrapBracket("(", ")")

vk1D & vkBA::  ; コロン
{
    if GetKeyState("Shift", "P")
        WrapBracket("*", "*")
    else
        Send("{Blind}{End}{Enter}")
}
