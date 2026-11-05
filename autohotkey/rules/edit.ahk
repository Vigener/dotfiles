#Requires AutoHotkey v2.0

; ==============================================================================
; [EDIT] 無変換レイヤー = Karabiner 英数レイヤー（edit.ts）
;
; 翻訳:
;   Cmd            → Ctrl
;   Cmd+Opt        → Ctrl+Alt
;   Cmd+Shift      → Ctrl+Shift（{Blind} で物理 Shift を残す）
;   Cmd+← / →      → Home / End          （行頭 / 行末）
;   Cmd+↑ / ↓      → Ctrl+Home / Ctrl+End （文頭 / 文末）
;   Opt+← / →      → Ctrl+← / Ctrl+→     （単語。Mac では Opt と Ctrl が同じ送出に潰れる）
;   Opt+↑ / ↓      → Alt+↑ / Alt+↓       （段落・行移動）
;   Cmd+[ / ]      → Alt+← / Alt+→       （戻る / 進む。Ctrl+[ はインデントなので使わない）
;   英数+1..9      → Ctrl+1..9           （タブ / スレッド。Ghostty の herdr はアプリ枠が空なので未収録）
;   英数+Shift+3/4 → ファイル保存、Ctrl を足すとクリップボード
;
; 入れないもの: Vivaldi / Ghostty / herdr / 両親指（英数+かな）
; ==============================================================================

; --- 1. カーソル移動 (H J K L) ---
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

; --- 3. 削除 (O, @) ---
vk1D & o::
{
    if GetKeyState("Ctrl", "P")
        Send("{Blind}^{BackSpace}")
    else
        Send("{Blind}{BackSpace}")
}

; JIS「@」(vkC0)。Mac の open_bracket = Forward Delete
vk1D & vkC0::
{
    if GetKeyState("Ctrl", "P")
        Send("{Blind}^{Delete}")
    else
        Send("{Blind}{Delete}")
}

; --- 4. Esc / Enter / Space ---
vk1D & q::Send("{Blind}{Escape}")

; JIS「;」(vkBB) → Enter。Shift は残るので Shift+Enter も通る
vk1D & vkBB::Send("{Blind}{Enter}")

; 英数+Shift+Enter → Ctrl+Shift+Enter。修飾なしの Enter はそのまま
vk1D & Enter::
{
    if GetKeyState("Shift", "P")
        Send("^+{Enter}")
    else
        Send("{Enter}")
}

; 英数+Space → Cmd+Space。Windows 側は PowerToys Run（Alt+Space）
vk1D & Space::Send("!{Space}")

; --- 5. 一行選択 (D) ---
; Mac: Cmd+Left → Shift+Cmd+Right。Windows: Home → Shift+End
vk1D & d::Send("{Home}+{End}")

; --- 6. Cmd 模倣。S/D/F/Q/;/@ は上で別機能 ---
vk1D & z::Send("{Blind}^z")
vk1D & y::Send("{Blind}^y")
vk1D & x::Send("{Blind}^x")
vk1D & c::Send("{Blind}^c")
vk1D & v::Send("{Blind}^v")
vk1D & a::Send("{Blind}^a")
vk1D & n::Send("{Blind}^n")
vk1D & w::Send("{Blind}^w")
vk1D & p::Send("{Blind}^p")
vk1D & u::Send("{Blind}^u")
vk1D & g::Send("{Blind}^g")
vk1D & e::Send("{Blind}^e")
vk1D & r::Send("{Blind}^r")

; 英数+Ctrl+T → Ctrl+Alt+T（Mac の Cmd+Opt+T）。Shift は {Blind} で Ctrl+Shift+T
vk1D & t::
{
    if GetKeyState("Ctrl", "P")
        Send("^!t")
    else
        Send("{Blind}^t")
}

; 英数+Shift+B / 英数+Ctrl+B → Ctrl+Alt+B（右パネル）。素の B は Ctrl+B
vk1D & b::
{
    if GetKeyState("Ctrl", "P") || GetKeyState("Shift", "P")
        Send("^!b")
    else
        Send("{Blind}^b")
}

; JIS [ ]。戻る / 進むはブラウザもエディタも Alt+矢印
vk1D & vkDB::Send("!{Left}")
vk1D & vkDD::Send("!{Right}")

vk1D & vkBF::Send("{Blind}^/")

; --- 7. スクリーンショットとタブ番号 ---
; Shift+3/4 はスクショ（3/4 の Ctrl+数字より先）。Ctrl 追加でクリップボード
vk1D & 1::EisuuNumber(1)
vk1D & 2::EisuuNumber(2)
vk1D & 3::EisuuNumber(3)
vk1D & 4::EisuuNumber(4)
vk1D & 5::EisuuNumber(5)
vk1D & 6::EisuuNumber(6)
vk1D & 7::EisuuNumber(7)
vk1D & 8::EisuuNumber(8)
vk1D & 9::EisuuNumber(9)

EisuuNumber(n) {
    try {
        shift := GetKeyState("Shift", "P")
        ctrl := GetKeyState("Ctrl", "P")
        if shift && (n = 3 || n = 4) {
            dest := ctrl ? "clip" : "file"
            if (n = 3)
                EisuuShotFull(dest)
            else
                EisuuShotRegion(dest)
        } else {
            Send("{Blind}^" n)
        }
    } catch as err {
        ToolTip("スクショ失敗: " err.Message)
        SetTimer(() => ToolTip(), -2000)
    } finally {
        KeyWait(String(n))
    }
}
