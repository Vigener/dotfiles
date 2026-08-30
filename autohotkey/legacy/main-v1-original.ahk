#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
;実装したい機能
; 無変換+oを受け取ったときに、Ctrlの状態を確認して、押されていた場合にIMEの状態に応じて、Ctrl+Zまたは、Ctrl+backspaceを送るようにする。押されていないときはBackspaceを送る

; メモ
; ; vkBB
; : vkBA
; , vkBC
; ^ Ctrl
; + Shift
; ! Alt
; # Win
; vk1D 無変換
; vk1C 変換
; vkF2 カナかな


; 別アプリによる設定
; ChgKeyでCapsLockをCtrlに変更済

; >>>事前準備関連
#UseHook
; -----------------------------------------------------------
; 関数の定義
; >>>IME関連
;IMEのON/OFF に関する関数の定義 ;0:英語入力 1:日本語入力
IME_SET(SetSts, WinTitle="A") {
    ControlGet,hwnd,HWND,,,%WinTitle%
    if	(WinActive(WinTitle))	{
        ptrSize := !A_PtrSize ? 4 : A_PtrSize
        VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
        NumPut(cbSize, stGTI, 0, "UInt") ;	DWORD   cbSize;
        hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
        ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
    }

    return DllCall("SendMessage"
    , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
    , UInt, 0x0283 ;Message : WM_IME_CONTROL
    , Int, 0x006 ;wParam  : IMC_SETOPENSTATUS
    , Int, SetSts) ;lParam  : 0 or 1
}
;IMEの状態を取得する関数の定義 0:英語入力 1:日本語入力
IME_GET(WinTitle="A") {
    ControlGet,hwnd,HWND,,,%WinTitle%
    if (WinActive(WinTitle)) {
        ptrSize := !A_PtrSize ? 4 : A_PtrSize
        VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
        NumPut(cbSize, stGTI, 0, "UInt") ; DWORD cbSize;
        hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
        ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
    }
    return DllCall("SendMessage"
    , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
    , UInt, 0x0283 ;Message : WM_IME_CONTROL
    , Int, 0x0005 ;wParam  : IMC_GETOPENSTATUS
    , Int, 0) ;lParam  : 0
}
; IMEreset関数を作成
IMEreset() {
    ;60秒以上操作がされていない場合、IMEをOffにする
    if (A_TimeIdleKeyboard > 90000) {
        if (IME_GET()) {
            IME_SET(0)
        }
    }
}
; -----------------------------------------------------------

; -----------------------------------------------------------
;# 定期実行の設定
; -----------------------------------------------------------
#Persistent
;IMEresetを10秒ごとに実行
SetTimer, IMEreset, 100000
Return
; -----------------------------------------------------------

; -----------------------------------------------------------
;# テスト実装(test)
; -----------------------------------------------------------
; ]::Send, {Enter}  ; ]キーでEnterを送信
; [::Send, {BackSpace}  ; [キーでBackSpaceを送信
; Shift + ]でShift+Enterを送信
; +]::Send, +{Enter}
; ;-----------------------------


WrapBracket(x,y){
    Backup := ClipboardAll
    Clipboard =
    Send, ^c
    Sleep,50
    IfInString, Clipboard, `r`n
    {
        Clipboard = 
        ClipStatus := 0 ;からっぽのカッコが送られるので0
    }Else if (Clipboard = ""){
        ClipStatus := 0
    }else{
        ClipStatus := 1 ;中身があるので1
        }
    ;  StringReplace, Clipboard, Clipboard, `r`n, , All
    Sleep,50
    Clipboard = %x%%Clipboard%%y%
    Sleep, 50
    Send,^v
    Sleep,50
    if (ClipStatus = 0){
        send,{Left}
    }Else{
        }
    Clipboard := Backup
    ClipStatus = 
}
; 変換キー+8
vk1C & 8::WrapBracket("(",")")
; 変換キー+[ (Shiftで"{")
vk1C & [::
    ; 英語入力モードの時のみにする
    if (IME_GET() = 0)
        if GetKeyState("Shift", "P")
            WrapBracket("{","}")
        else
            WrapBracket("[","]")
    else
        Send, [
        Send, ]
        Send, {Left}
Return
; 変換キー+]
; -----------------------------------------------------------

; -----------------------------------------------------------
;# AHKの設定
; -----------------------------------------------------------
;頻繁にスクリプトを変える場合に便利
; Reload script when vk1D and 0 are pressed
~vk1D & 0::
    Reload
    return
~vk1D & 8::Edit		;このスクリプトを編集


; -----------------------------------------------------------

; -----------------------------------------------------------
;# Hotstringの設定
; -----------------------------------------------------------
#Hotstring *
#Hotstring O
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
::0;;::08021311283
::0--::08021311283
::0@@::08021311283
::t@@::08021311283
::t//::08021311283
::2;;::202310970
::d//::
    FormatTime, dateStr, , yyyy/MM/dd
    Send, %dateStr%
Return ;日付を入力 ex)2000/01/01
::d--::
    FormatTime, dateStr, , yyyy-MM-dd
    Send, %dateStr%
Return ;日付を入力 ex)2000-01-01
::t,,::
    FormatTime, dateStr, , HH:mm
    Send, %dateStr%
Return ;時刻を入力 ex)00:00
::d;;::
    FormatTime, dateStr, , yyMMdd
    Send, %dateStr%
Return ;日付を入力 ex)200101
; -----------------------------------------------------------

; -----------------------------------------------------------
;# ウィンドウの移動系
; -----------------------------------------------------------
; Alt+j,kでアクティブウィンドウの最大化・最小化
!j::WinMinimize, A
!k::WinMaximize, A
!h::Send, #{Left}
!l::Send, #{Right}
; -----------------------------------------------------------

; -----------------------------------------------------------
; 親指シフトの導入案
; -----------------------------------------------------------
; vkF2::
;     Send, {Blind}{Shift}
; Return
; 右Shiftキーを使わないようにするために無効化


; -----------------------------------------------------------

; -----------------------------------------------------------
;# アプリ切り替え関連
; -----------------------------------------------------------

; 変換キーとeでEdgeを起動、またはアクティブにする
vk1C & e::
    if WinExist("ahk_exe msedge.exe")
        ; Edgeがアクティブになっている場合は、最小化する
        if WinActive("ahk_exe msedge.exe")
            WinMinimize, ahk_exe msedge.exe
        else
            WinActivate, ahk_exe msedge.exe
    else
        Run, C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe
Return

; 変換キーとmでVScodeを起動、またはアクティブにする
vk1C & m::
    if WinExist("ahk_exe Code.exe")
        ; VScodeがアクティブになっている場合は、最小化する
        if WinActive("ahk_exe Code.exe")
            WinMinimize, ahk_exe Code.exe
        else
            WinActivate, ahk_exe Code.exe
    else
        ; VSCodeを起動することをメッセージで表示
        Run, C:\Users\vgnri\AppData\Local\Programs\Microsoft VS Code\Code.exe
Return

; vk1C & b::
;     if WinExist("ahk_exe Cursor.exe")
;         ; Cursorがアクティブになっている場合は、最小化する
;         if WinActive("ahk_exe Cursor.exe")
;             WinMinimize, ahk_exe Cursor.exe
;         else
;             WinActivate, ahk_exe Cursor.exe
;     else
;         Run, C:\Users\vgnri\AppData\Local\Programs\Cursor\Cursor.exe
; Return

vk1C & o::
    if WinExist("ahk_exe Obsidian.exe")
        ; Obsidianがアクティブになっている場合は、最小化する
        if WinActive("ahk_exe Obsidian.exe")
            WinMinimize, ahk_exe Obsidian.exe
        else
            WinActivate, ahk_exe Obsidian.exe
    else
        Run, C:\Users\vgnri\AppData\Local\Programs\obsidian\Obsidian.exe
Return

; 変換キーとdでDiscordを起動、またはアクティブにする
vk1C & d::
    if WinExist("ahk_exe Discord.exe")
        ; Discordがアクティブになっている場合は、最小化する
        if WinActive("ahk_exe Discord.exe")
            WinMinimize, ahk_exe Discord.exe
        else
            WinActivate, ahk_exe Discord.exe
    else
        ; Windowsキー+7を押す
        Send, #7
Return

; # 試験的にchromeをカンマに、notionをnに割り当て
; 変換キーとn(b: nがcursorに割り当てられている場合)でchromeを起動、またはアクティブにする
; vk1C & n::
; ; vk1C & vkBC::
;     if WinExist("ahk_exe Comet.exe")
;         ; chromeがアクティブになっている場合は、最小化する
;         if WinActive("ahk_exe Comet.exe")
;             WinMinimize, ahk_exe Comet.exe
;         else
;             WinActivate, ahk_exe Comet.exe
;     else
;         ; "C:\Users\vgnri\AppData\Local\Perplexity\Comet\Application\comet.exe"
;         Run, C:\Users\vgnri\AppData\Local\Perplexity\Comet\Application\comet.exe
; Return

; 変換キーとbでCursorを起動、またはアクティブにする
vk1C & n::
    if WinExist("ahk_exe Chrome.exe")
        ; Cursorがアクティブになっている場合は、最小化する
        if WinActive("ahk_exe Chrome.exe")
            WinMinimize, ahk_exe Chrome.exe
        else
            WinActivate, ahk_exe Chrome.exe
    else
        Run, C:\Program Files\Google\Chrome\Application\chrome.exe
Return

; vk1C & v::Send, #3 ; Vivaldi
vk1C & v::
    if WinExist("ahk_exe Vivaldi.exe")
        ; Vivaldiがアクティブになっている場合は、最小化する
        if WinActive("ahk_exe Vivaldi.exe")
            WinMinimize, ahk_exe Vivaldi.exe
        else
            WinActivate, ahk_exe Vivaldi.exe
    else
        Run, C:\Users\vgnri\AppData\Local\Vivaldi\Application\vivaldi.exe
Return

; Warp
vk1C & p::
    if WinExist("ahk_exe Warp.exe")
        ; Warpがアクティブになっている場合は、最小化する
        if WinActive("ahk_exe Warp.exe")
            WinMinimize, ahk_exe Warp.exe
        else
            WinActivate, ahk_exe Warp.exe
    else
        Run, C:\Users\vgnri\AppData\Local\Programs\Warp\warp.exe
Return

; Antigravity
vk1C & a::
    if WinExist("ahk_exe antigravity.exe")
        ; Antigravityがアクティブになっている場合は、最小化する
        if WinActive("ahk_exe antigravity.exe")
            WinMinimize, ahk_exe antigravity.exe
        else
            WinActivate, ahk_exe antigravity.exe
    else
        ; "C:\Users\vgnri\AppData\Local\Programs\Antigravity\Antigravity.exe"
        Run, C:\Users\vgnri\AppData\Local\Programs\antigravity\antigravity.exe
Return

; 変換キー + l : LINE (時間制限付き: 20時～翌8時のみ)
vk1C & l::
FormatTime, NowTime, , HH
if ((NowTime >= 18) or (NowTime < 8)) {
    if WinExist("ahk_class Qt663QWindowIcon") 
        if WinActive("ahk_class Qt663QWindowIcon")
            WinMinimize, ahk_class Qt663QWindowIcon
        else
            WinActivate, ahk_class Qt663QWindowIcon
    else
        Run, C:\Users\vgnri\AppData\Local\LINE\bin\LineLauncher.exe
}
Return

; カタカナひらがなローマ字キー2連打でAltTabMenuキーのタスク切り替えとして割当
IsAltTabMenu := false
vkF2 & RAlt::
    Send !^{Tab}
    IsAltTabMenu := true
return
vk1C & vkF2::
; +vk1c::
    Send, !^{Tab}
    IsAltTabMenu := true
return

; 無変換キー + SpaceキーでEnter
vk1D & Space::Send, {Enter} 


#If (IsAltTabMenu)
j::Send {Down}
k::Send {Up}
h::Send {Left}
l::Send {Right}
Enter::
    Send {Enter}
    IsAltTabMenu := false
Return
Space::
    Send {Space}
    IsAltTabMenu := false
Return
#If
    ; -----------------------------------------------------------

; -----------------------------------------------------------
;# IME関連の設定
; -----------------------------------------------------------

; 変更後
vk1C::IME_SET(0)
vk1C & j::IME_SET(1) ; 変換キーとjでIMEを日本語に設定
vk1C & k::IME_SET(0) ; 変換キーとkでIMEを英語に設定
vk1C & vk1D::IME_SET(1)


; Ctrl+backspaceで日本語入力・英語入力どちらの場合でも打ち始めた文字を削除
Ctrl & BackSpace::
    ime := IME_GET()
    If (ime) {
        Send, ^z
    } Else {
        Send, {Blind}^{BackSpace}
    }
Return
; Ctrl+DeleteでIMEの切り替え　(∵Ctrl+BackSpaceで消去した後に、IME切り替えを迅速に行うため)
Ctrl & Delete::
    ime := IME_GET()
    If (ime) {
        IME_SET(0)
    } Else {
        IME_SET(1)
    }
Return
; -----------------------------------------------------------l

; -----------------------------------------------------------
;# キャレット移動関連の設定
; -----------------------------------------------------------
vk1D & H::Send,{Blind}{Left}
vk1D & J::Send,{Blind}{Down}
vk1D & K::Send,{Blind}{Up}
vk1D & L::Send,{Blind}{Right}
vk1D & s::Send, {Blind}{Home} ;Home
vk1D & f::Send, {Blind}{End} ;End
; -----------------------------------------------------------

; -----------------------------------------------------------
;vivaldi用の設定
; -----------------------------------------------------------
Ctrl & o::
    If (GetKeyState("Space", "P")) {
        Send, +^o
    } Else {
        Send, ^o
    }
Return ;サイドパネルでメモを開く用
Ctrl & i::
    If (GetKeyState("Space", "P")) {
        Send, !^q
    } Else {
        Send, ^i
    }
Return ;サイドパネルでstackeditを開く用
vk1D & w::Send, !w ;ウィンドウパネルを開く用のAlt+wに無変換+wを割り当て
vk1D & e::Send, {Blind}^e ;無変換キー+eでCtrl+e
vk1D & m::Send, {Blind}!m ;無変換キー+mでAlt+mでメモを開く
; -----------------------------------------------------------


; -----------------------------------------------------------
;　特殊キー代替系の設定
; -----------------------------------------------------------
vk1D & Enter:: ; 行挿入(Ctrlを押している場合は、現在の行の上に、押していない場合は行の下に挿入)
    If (GetKeyState("Ctrl", "P")) {
        Send, {Up}{End}{Enter}
    } Else {
        Send, {End}{Enter}
    }
Return
; >>> 変換キー
vk1C & vkBB::Send, {Blind}{End}{Enter} ; 変換キー + ;
vk1C & @::Send, {Blind}{BackSpace}{BackSpace}{BackSpace} ; 変換キー + @でBackSpace×3
; >>> 無変換キー
vk1D & vkBB::Send, {Blind}{Enter} ; 無変換キー + ;
vk1D & vkBA::Send,{Blind}{End}{Enter} ; 無変換キー + :
vk1D & P::Send,{Blind}{Ctrl}{BackSpace} ; 無変換キー + Pで単語ごとに削除
; vk1D & O::Send,{Blind}{BackSpace}
; 無変換 + Shift + oでCtrl+BackSpaceとCtrl+Deleteを切り替えるを順番に実行
vk1D & o::
    If (GetKeyState("Shift", "P")) {
        Send, ^{BackSpace}
        Send, ^{Delete}
        return
    } Else {
        Send, {Blind}{BackSpace}
        return 
    }
    Return

vk1D & @::Send,{Blind}{Del}
vk1D & Q::Send,{Blind}{Esc}
; vk1C & P::Send,{Blind}{Esc}
; -----------------------------------------------------------

; -----------------------------------------------------------
; vimもどき
; -----------------------------------------------------------
vk1D & d::Send, {Blind}{Home}+{End}		;1行選択
; 単語選択
vk1D & r::Send, {Blind}+{Right}
; -----------------------------------------------------------

; -----------------------------------------------------------
; 音楽操作系
; -----------------------------------------------------------
; カナかなキーに割当を行った際に一度以下のいずれかのコードを実行すると変換キーと無変換キーにもカナかなキーと同様の役割が割り当てられてしまう挙動がある。（未解決））
vk1C & h::Send, {Media_Play_Pause}
; vkF2 & j::Send, {Media_Prev}
; vkF2 & l::Send, {Media_Next}
vk1C & u::Send, {Volume_Up}
vk1C & i::Send, {Volume_Down}
vk1C & y::Send, {Volume_Mute}
; vkF2 & m::Send, {Volume_Mute}

; 変換キー + g でSpotifyの再生/一時停止（これ天才）、
vk1C & g::
	SetTitleMatchMode, 2
	IfWinNotExist, ahk_exe Spotify.exe
	{
		; Run, Spotify
        ; "C:\Users\vgnri\AppData\Roaming\Spotify\Spotify.exe"
        Run, C:\Users\vgnri\AppData\Roaming\Spotify\Spotify.exe
		Loop, 10
		{
			IfWinActive, Spotify
				break
			Sleep 50
		}
		Sleep 1000
		WinClose, Spotify
	}
	if spotifyPID := "" 
	{
		WinGet, ProcessList, List, ahk_exe Spotify.exe
		Loop, %ProcessList% {
			id := ProcessList%A_Index%
			WinGetTitle, title , ahk_id %id%
			if (title = Spotify Premium) {
				spotifyPID = ahk_id %id%
			}
		}
	}
	PostMessage, 0x319, , 0xE0000, , %spotifyPID%
	return

; -----------------------------------------------------------
;特殊設定
; -----------------------------------------------------------
vk1D::Return
; powershell上で、無変換キー単体が押されたときになぜか@が表示される
; この挙動を防ぐために、無変換キー単体が押されたときに何もしないように設定
; -----------------------------------------------------------
; ===== YouTube Music バックグラウンド再生制御 (AutoHotkey v1対応・デバッグ版) =====
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; 【重要】PowerShellスクリプトのパス
; ※ AHKスクリプトと同じフォルダに置く想定です
psScriptPath := A_ScriptDir . "\"

; プレイリストURL
playlistBGM := "https://music.youtube.com/playlist?list=PLWdDkHo0RZF-yhc1r2H_yOP1kzyJW_8Yn"
playlistFav := "https://music.youtube.com/playlist?list=LRYR7OqEbKZk6dgay2HgI_j6OyS8rCW9-rRzl"

^!q::
    RunPlaylist(psScriptPath, playlistBGM, "BGM")
return

^!f::
    RunPlaylist(psScriptPath, playlistFav, "Favorites")
return

RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
return

; 共通関数
RunPlaylist(scriptPath, url, label) {
    ; ファイル存在確認
    if !FileExist(scriptPath) {
        MsgBox, 16, Error, Script not found:`n%scriptPath%
        return
    }

    ToolTip, Playing %label% playlist...
    SetTimer, RemoveToolTip, 2000

    ; 【重要】Runコマンドの組立
    ; -WindowStyle Hidden: 画面を表示させない
    ; -ExecutionPolicy Bypass: 実行権限エラー回避
    ; -File "..." : パスをダブルクォートで囲む
    ; 引数のURLもダブルクォートで囲む
    
    cmd := "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File """ . scriptPath . """ -PlaylistUrl """ . url . """"
    
    ; RunWaitではなくRunを使用（AHKをブロックしないため）
    ; Hide オプションで黒い画面を一瞬たりとも出さない
    Run, %cmd%,, Hide
}
; -----------------------------------------------------------


#UseHook off