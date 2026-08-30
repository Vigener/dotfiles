#Requires AutoHotkey v2.0

; ==============================================================================
; [WINDOW] 変換レイヤー & ウィンドウ操作 (Macのかなレイヤーに完全対応)
; - 仮想デスクトップ: H (左デスクトップ Win+Ctrl+Left), L (右デスクトップ Win+Ctrl+Right)
; - ウィンドウ状態:   J (最小化 / 隠す), K (最大化)
; - 画面スナップ:     , (左半分 Win+Left), . (右半分 Win+Right), / (最大化 Win+Up)
; - ディスプレイ移動: ろキー (\) (次のディスプレイ Win+Shift+Right)
; - タスクビュー:     ; (Win+Tab)
; - タスク切替:       Tab (Alt+Ctrl+Tab で固定タスク切替 -> HJKLで選択、Enter/Spaceで決定)
; - グローバル操作:   Alt+H/J/K/L でスナップ/最大化/最小化
; ==============================================================================

; --- タスク切り替えモード管理 ---
global IsAltTabActive := false

; --- 1. 仮想デスクトップ操作 (Spaces 相当) ---
vk1C & h::Send("#^{Left}")
vk1C & l::Send("#^{Right}")

; --- 2. ウィンドウ状態 (最小化・最大化) ---
vk1C & j::
{
    try {
        WinMinimize("A")
    } catch {
        Send("#{Down}")
    }
}

vk1C & k::
{
    try {
        WinMaximize("A")
    } catch {
        Send("#{Up}")
    }
}

; --- 3. ウィンドウ配置・スナップ (Raycast Window Management 相当) ---
vk1C & ,::Send("#{Left}")          ; 左半分
vk1C & .::Send("#{Right}")         ; 右半分
vk1C & vkBF::Send("#{Up}")         ; スラッシュで最大化
vk1C & vkBB::Send("#{Tab}")        ; セミコロンでタスクビュー (Mission Control)
vk1C & sc073::Send("#+{Right}")    ; ろキーで次のディスプレイへ移動

; --- 4. タスク切り替え (AltTab / Switch Windows) ---
; 変換 + Tab: 固定タスク切り替えを開き、Vimモードを開始
vk1C & Tab::
{
    global IsAltTabActive
    Send("!^{Tab}")
    IsAltTabActive := true
}

; 無変換 + Tab: 通常の Alt+Tab / Shift+Alt+Tab
vk1D & Tab::
{
    if GetKeyState("Shift", "P")
        Send("!+{Tab}")
    else
        Send("!{Tab}")
}

; --- 5. タスク切り替え中の Vim風キーバインド ---
#HotIf IsAltTabActive
h::Send("{Left}")
j::Send("{Down}")
k::Send("{Up}")
l::Send("{Right}")
Enter::
{
    global IsAltTabActive
    Send("{Enter}")
    IsAltTabActive := false
}
Space::
{
    global IsAltTabActive
    Send("{Space}")
    IsAltTabActive := false
}
Escape::
{
    global IsAltTabActive
    Send("{Escape}")
    IsAltTabActive := false
}
#HotIf

; --- 6. グローバルなウィンドウ操作ショートカット ---
!h::Send("#{Left}")
!l::Send("#{Right}")
!j::
{
    try {
        WinMinimize("A")
    } catch {
        Send("#{Down}")
    }
}
!k::
{
    try {
        WinMaximize("A")
    } catch {
        Send("#{Up}")
    }
}
