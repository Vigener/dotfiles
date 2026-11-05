#Requires AutoHotkey v2.0
#InstallMouseHook

; ==============================================================================
; 英数+Shift+3/4 の保存 / クリップボード振り分け
; Mac:   Shift+3/4 = ファイル、Ctrl を足すとクリップボード
; Windows の PrintScreen / Win+Shift+S は宛先が逆なので、ここでは自分で撮る
; 保存先は「スクリーンショット」フォルダ（Win+PrintScreen と同じ場所）
; ==============================================================================

global EisuuShotState := {cancel: false}

EisuuShotCancel(*) {
    global EisuuShotState
    EisuuShotState.cancel := true
}

; dest: "file" または "clip"
EisuuShotFull(dest) {
    scr := EisuuVirtualScreen()
    EisuuCapture(scr.x, scr.y, scr.w, scr.h, dest)
}

EisuuShotRegion(dest) {
    global EisuuShotState
    EisuuShotState.cancel := false
    Hotkey("*Escape", EisuuShotCancel, "On")
    prevMouse := A_CoordModeMouse
    CoordMode("Mouse", "Screen")
    overlay := ""
    bars := []
    try {
        scr := EisuuVirtualScreen()
        overlay := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x80000")
        overlay.BackColor := "000000"
        WinSetTransparent(40, overlay.Hwnd)
        overlay.Show(Format("x{} y{} w{} h{}", scr.x, scr.y, scr.w, scr.h))
        loop 4 {
            g := Gui("+AlwaysOnTop -Caption +ToolWindow")
            g.BackColor := "FF3B30"
            bars.Push(g)
        }
        ToolTip("ドラッグで範囲。Esc / 右クリックでキャンセル")
        rect := EisuuDragRect(bars)
        EisuuHideShotUi(overlay, bars)
        overlay := ""
        bars := []
        ToolTip()
        Sleep(100)
        if IsObject(rect)
            EisuuCapture(rect.x, rect.y, rect.w, rect.h, dest)
    } finally {
        Hotkey("*Escape", "Off")
        CoordMode("Mouse", prevMouse)
        EisuuHideShotUi(overlay, bars)
    }
}

EisuuDragRect(bars) {
    global EisuuShotState
    deadline := A_TickCount + 30000
    cross := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32515, "Ptr")
    while (A_TickCount < deadline) {
        DllCall("SetCursor", "Ptr", cross)
        if EisuuShotState.cancel || GetKeyState("RButton", "P")
            return ""
        if GetKeyState("LButton", "P")
            break
        Sleep(10)
    }
    if !GetKeyState("LButton", "P")
        return ""
    MouseGetPos(&x1, &y1)
    x2 := x1, y2 := y1
    while GetKeyState("LButton", "P") {
        DllCall("SetCursor", "Ptr", cross)
        if EisuuShotState.cancel || GetKeyState("RButton", "P")
            return ""
        MouseGetPos(&x2, &y2)
        EisuuShowRubber(bars, x1, y1, x2, y2)
        Sleep(10)
    }
    x := Min(x1, x2)
    y := Min(y1, y2)
    w := Abs(x2 - x1)
    h := Abs(y2 - y1)
    if (w < 3 || h < 3)
        return ""
    return {x: x, y: y, w: w, h: h}
}

EisuuShowRubber(bars, x1, y1, x2, y2) {
    x := Min(x1, x2)
    y := Min(y1, y2)
    w := Max(Abs(x2 - x1), 1)
    h := Max(Abs(y2 - y1), 1)
    t := 2
    bars[1].Show(Format("x{} y{} w{} h{} NA", x, y, w, t))
    bars[2].Show(Format("x{} y{} w{} h{} NA", x, y + h - t, w, t))
    bars[3].Show(Format("x{} y{} w{} h{} NA", x, y, t, h))
    bars[4].Show(Format("x{} y{} w{} h{} NA", x + w - t, y, t, h))
}

EisuuHideShotUi(overlay, bars) {
    if IsObject(overlay) {
        try overlay.Destroy()
    }
    if IsObject(bars) {
        for g in bars {
            try g.Destroy()
        }
    }
}

EisuuCapture(x, y, w, h, dest) {
    hBM := EisuuBlit(x, y, w, h)
    try {
        if (dest = "clip") {
            EisuuBitmapToClipboard(hBM)
            ToolTip("クリップボードにコピーした")
        } else {
            path := EisuuShotsDir() "\Screenshot " FormatTime(, "yyyy-MM-dd HH.mm.ss") ".png"
            EisuuSavePng(hBM, path)
            SplitPath(path, &name)
            ToolTip("保存した: " name)
        }
        SetTimer(() => ToolTip(), -1500)
    } finally {
        DllCall("DeleteObject", "Ptr", hBM)
    }
}

EisuuVirtualScreen() {
    return {
        x: DllCall("GetSystemMetrics", "Int", 76, "Int"),
        y: DllCall("GetSystemMetrics", "Int", 77, "Int"),
        w: DllCall("GetSystemMetrics", "Int", 78, "Int"),
        h: DllCall("GetSystemMetrics", "Int", 79, "Int")
    }
}

EisuuShotsDir() {
    static dir := ""
    if (dir != "")
        return dir
    fid := Buffer(16, 0)
    DllCall("ole32\CLSIDFromString", "WStr", "{B7BEDE81-DF94-4682-A7D8-57A52620B86F}", "Ptr", fid.Ptr)
    pathPtr := 0
    hr := DllCall("shell32\SHGetKnownFolderPath", "Ptr", fid.Ptr, "UInt", 0, "Ptr", 0, "Ptr*", &pathPtr)
    if (hr = 0 && pathPtr) {
        dir := StrGet(pathPtr, "UTF-16")
        DllCall("ole32\CoTaskMemFree", "Ptr", pathPtr)
    } else {
        dir := EnvGet("USERPROFILE") "\Pictures\Screenshots"
    }
    DirCreate(dir)
    return dir
}

EisuuBlit(x, y, w, h) {
    hDC := DllCall("GetDC", "Ptr", 0, "Ptr")
    mDC := DllCall("CreateCompatibleDC", "Ptr", hDC, "Ptr")
    hBM := DllCall("CreateCompatibleBitmap", "Ptr", hDC, "Int", w, "Int", h, "Ptr")
    old := DllCall("SelectObject", "Ptr", mDC, "Ptr", hBM, "Ptr")
    DllCall("BitBlt", "Ptr", mDC, "Int", 0, "Int", 0, "Int", w, "Int", h,
        "Ptr", hDC, "Int", x, "Int", y, "UInt", 0x00CC0020)
    DllCall("SelectObject", "Ptr", mDC, "Ptr", old)
    DllCall("DeleteDC", "Ptr", mDC)
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)
    if !hBM
        throw Error("BitBlt failed")
    return hBM
}

EisuuBitmapToClipboard(hBM) {
    bm := Buffer(A_PtrSize = 8 ? 32 : 24, 0)
    if !DllCall("GetObject", "Ptr", hBM, "Int", bm.Size, "Ptr", bm.Ptr)
        throw Error("GetObject")
    w := NumGet(bm, 4, "Int")
    h := NumGet(bm, 8, "Int")
    hdrSize := 40
    stride := w * 4
    imgSize := stride * h
    bi := Buffer(hdrSize, 0)
    NumPut("UInt", 40, bi, 0)
    NumPut("Int", w, bi, 4)
    NumPut("Int", h, bi, 8)
    NumPut("UShort", 1, bi, 12)
    NumPut("UShort", 32, bi, 14)
    NumPut("UInt", imgSize, bi, 20)
    bits := Buffer(imgSize, 0)
    hDC := DllCall("GetDC", "Ptr", 0, "Ptr")
    got := DllCall("GetDIBits", "Ptr", hDC, "Ptr", hBM, "UInt", 0, "UInt", h,
        "Ptr", bits.Ptr, "Ptr", bi.Ptr, "UInt", 0)
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)
    if (got = 0)
        throw Error("GetDIBits")
    total := hdrSize + imgSize
    hGlobal := DllCall("GlobalAlloc", "UInt", 0x0002, "Ptr", total, "Ptr")
    p := DllCall("GlobalLock", "Ptr", hGlobal, "Ptr")
    DllCall("RtlMoveMemory", "Ptr", p, "Ptr", bi.Ptr, "UPtr", hdrSize)
    DllCall("RtlMoveMemory", "Ptr", p + hdrSize, "Ptr", bits.Ptr, "UPtr", imgSize)
    DllCall("GlobalUnlock", "Ptr", hGlobal)
    opened := false
    loop 10 {
        if DllCall("OpenClipboard", "Ptr", 0) {
            opened := true
            break
        }
        Sleep(20)
    }
    if !opened {
        DllCall("GlobalFree", "Ptr", hGlobal)
        throw Error("OpenClipboard")
    }
    DllCall("EmptyClipboard")
    if !DllCall("SetClipboardData", "UInt", 8, "Ptr", hGlobal, "Ptr") {
        DllCall("CloseClipboard")
        DllCall("GlobalFree", "Ptr", hGlobal)
        throw Error("SetClipboardData")
    }
    DllCall("CloseClipboard")
}

EisuuSavePng(hBM, path) {
    EisuuGdipStart()
    pBitmap := 0
    if DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hBM, "Ptr", 0, "Ptr*", &pBitmap) || !pBitmap
        throw Error("GdipCreateBitmapFromHBITMAP")
    try {
        clsid := Buffer(16, 0)
        if DllCall("ole32\CLSIDFromString", "WStr", "{557CF406-1A04-11D3-9A73-0000F81EF32E}", "Ptr", clsid.Ptr)
            throw Error("PNG encoder")
        if DllCall("gdiplus\GdipSaveImageToFile", "Ptr", pBitmap, "WStr", path, "Ptr", clsid.Ptr, "Ptr", 0)
            throw Error("GdipSaveImageToFile")
    } finally {
        DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
    }
}

EisuuGdipStart() {
    static token := 0
    if token
        return
    si := Buffer(24, 0)
    NumPut("UInt", 1, si, 0)
    if DllCall("gdiplus\GdiplusStartup", "Ptr*", &token, "Ptr", si.Ptr, "Ptr", 0)
        throw Error("GdiplusStartup")
}
