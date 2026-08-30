#Requires AutoHotkey v2.0

; ==============================================================================
; ✍️ 括弧自動囲みヘルパー (AutoHotkey v2対応)
; - テキスト選択中: 選択テキストを openChar と closeChar で囲む
; - 非選択中: openChar closeChar を入力し、カーソルをカッコの間に移動
; ==============================================================================

WrapBracket(openChar, closeChar) {
    savedClip := ClipboardAll()
    A_Clipboard := ""
    Send("^c")
    if !ClipWait(0.1) {
        ; テキストが選択されていなかった場合
        A_Clipboard := savedClip
        SendText(openChar . closeChar)
        Send("{Left " . StrLen(closeChar) . "}")
        return
    }

    selectedText := A_Clipboard
    ; 改行を含むかどうかの判定
    if InStr(selectedText, "`r") || InStr(selectedText, "`n") {
        A_Clipboard := savedClip
        SendText(openChar . closeChar)
        Send("{Left " . StrLen(closeChar) . "}")
        return
    }

    A_Clipboard := openChar . selectedText . closeChar
    Send("^v")
    Sleep(50)
    A_Clipboard := savedClip
}
