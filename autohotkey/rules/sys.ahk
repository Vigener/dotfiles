#Requires AutoHotkey v2.0

; ==============================================================================
; [SYS] コア・モディファイア設定 & IME連携
; - 無変換キー (vk1D): 単押しで IME OFF（英数）。長押し/併用で EDIT レイヤー
; - 変換キー   (vk1C): 単押しで IME ON（かな）。長押し/併用で WINDOW / APP レイヤー
; - JIS配列補正: ろキー (sc073) をバックスラッシュ (\) に変換
; - スマート編集: Ctrl+BackSpace で IME状態に応じた削除、Ctrl+Delete で IME切替
; ==============================================================================

; --- 単押し時の IME 切替 ---
; ※ 組み合わせ（vk1D & x, vk1C & x）が定義されている場合、単独で押して離した時のみ発火
vk1D::
{
    IME_SET(0)
}

vk1C::
{
    IME_SET(1)
}

; --- JIS配列補正 (ろキー) ---
; Shift+ろ のアンダースコア (_) はそのまま通し、単体ろキーを "\" (バックスラッシュ) に変換
+sc073::Send("{Blind}_")
sc073::SendText("\")

; --- Ctrl+BackSpace / Ctrl+Delete のスマート挙動 ---
; 日本語入力中に打ち始めた文字を一発消去 (Undo)、英語入力時は単語削除
^BackSpace::
{
    if (IME_IsON()) {
        Send("^z")
    } else {
        Send("{Blind}^{BackSpace}")
    }
}

; Ctrl+Delete で IME トグル
^Delete::
{
    if (IME_IsON()) {
        IME_SET(0)
    } else {
        IME_SET(1)
    }
}
