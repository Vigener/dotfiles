#Requires AutoHotkey v2.0

; ==============================================================================
; 🌐 IME制御ライブラリ (AutoHotkey v2対応)
; - IME_GET(WinTitle="A"): IMEの状態を取得 (0: 英語/OFF, 1: 日本語/ON)
; - IME_SET(SetSts, WinTitle="A"): IMEの状態を設定 (0: OFF, 1: ON)
; - IME_IsON(WinTitle="A"): IMEがONならtrue
; - IMEreset(): 一定時間無操作時に自動でIMEをOFFにする
; ==============================================================================

IME_GET(WinTitle := "A") {
    try {
        hwnd := WinGetID(WinTitle)
    } catch {
        return 0
    }

    if (WinActive(WinTitle)) {
        ptrSize := A_PtrSize
        cbSize := 4 + 4 + (ptrSize * 6) + 16
        stGTI := Buffer(cbSize, 0)
        NumPut("UInt", cbSize, stGTI, 0)
        if DllCall("GetGUIThreadInfo", "UInt", 0, "Ptr", stGTI.Ptr) {
            focusHwnd := NumGet(stGTI, 8 + ptrSize, "Ptr")
            if (focusHwnd)
                hwnd := focusHwnd
        }
    }

    imeWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd, "Ptr")
    if (!imeWnd)
        return 0

    ; WM_IME_CONTROL: 0x0283, IMC_GETOPENSTATUS: 0x0005
    return DllCall("SendMessage", "Ptr", imeWnd, "UInt", 0x0283, "UPtr", 0x0005, "Ptr", 0)
}

IME_SET(SetSts, WinTitle := "A") {
    try {
        hwnd := WinGetID(WinTitle)
    } catch {
        return
    }

    if (WinActive(WinTitle)) {
        ptrSize := A_PtrSize
        cbSize := 4 + 4 + (ptrSize * 6) + 16
        stGTI := Buffer(cbSize, 0)
        NumPut("UInt", cbSize, stGTI, 0)
        if DllCall("GetGUIThreadInfo", "UInt", 0, "Ptr", stGTI.Ptr) {
            focusHwnd := NumGet(stGTI, 8 + ptrSize, "Ptr")
            if (focusHwnd)
                hwnd := focusHwnd
        }
    }

    imeWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd, "Ptr")
    if (!imeWnd)
        return

    ; WM_IME_CONTROL: 0x0283, IMC_SETOPENSTATUS: 0x0006
    DllCall("SendMessage", "Ptr", imeWnd, "UInt", 0x0283, "UPtr", 0x0006, "Ptr", SetSts)
}

IME_IsON(WinTitle := "A") {
    return (IME_GET(WinTitle) != 0)
}

; 60秒以上操作がない場合に自動でIMEをOFFにして誤入力を防ぐ
IMEreset() {
    if (A_TimeIdleKeyboard > 60000) {
        if (IME_IsON()) {
            IME_SET(0)
        }
    }
}
