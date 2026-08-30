#Requires AutoHotkey v2.0

; ==============================================================================
; [HOTSTRING] 短縮入力・定型文
; - メールアドレス (個人 / 大学)
; - 電話番号 / 学籍番号
; - 日付 / 時刻
; ==============================================================================

#Hotstring *
#Hotstring O

; --- メールアドレス ---
::m@@::vgnrieee@gmail.com
::m//::vgnrieee@gmail.com
::v;;::vgnrieee@gmail.com

::m@s::s2310970@u.tsukuba.ac.jp
::m/s::s2310970@u.tsukuba.ac.jp
::m@u::s2310970@u.tsukuba.ac.jp
::m/u::s2310970@u.tsukuba.ac.jp
::s;;::s2310970@u.tsukuba.ac.jp
::s--::s2310970@u.tsukuba.ac.jp
::s@@::s2310970@u.tsukuba.ac.jp

; --- 電話番号 / 学籍番号 ---
::0;;::08021311283
::0--::08021311283
::0@@::08021311283
::t@@::08021311283
::t//::08021311283
::2;;::202310970

; --- 日付・時刻 ---
::d//::
{
    SendText(FormatTime(, "yyyy/MM/dd"))
}

::d--::
{
    SendText(FormatTime(, "yyyy-MM-dd"))
}

::t,,::
{
    SendText(FormatTime(, "HH:mm"))
}

::d;;::
{
    SendText(FormatTime(, "yyMMdd"))
}
