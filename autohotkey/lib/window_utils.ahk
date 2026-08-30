#Requires AutoHotkey v2.0

; ==============================================================================
; 🪟 ウィンドウ・アプリ操作ヘルパーライブラリ (AutoHotkey v2対応)
;    Mac (Karabiner) の toggleApp / toggleAppWithKey 相当の挙動をWindowsで実現
; ==============================================================================

/**
 * 通常アプリのトグル起動/最小化
 * - 既に最前面（アクティブ）なら最小化
 * - 起動中だがバックグラウンドなら最前面化
 * - 起動していなければ新規起動
 */
ToggleApp(exeName, runPath := "") {
    target := "ahk_exe " . exeName
    if (runPath == "")
        runPath := exeName

    if WinExist(target) {
        if WinActive(target) {
            WinMinimize target
        } else {
            WinActivate target
        }
    } else {
        try {
            Run runPath
        } catch as err {
            MsgBox("アプリの起動に失敗しました:`n" . runPath . "`n`nエラー: " . err.Message, "Launch Error", 16)
        }
    }
}

/**
 * キー送信付きアプリトグル (Macの toggleAppWithKey 相当)
 * - 最前面ならショートカットキー (例: "^3" Slackタブ) を送信
 * - 非アクティブなら最前面化してショートカットキーを送信
 * - 起動していなければ起動後にショートカットキーを送信
 */
ToggleAppWithKey(exeName, runPath, keyToSend) {
    target := "ahk_exe " . exeName
    if (runPath == "")
        runPath := exeName

    if WinExist(target) {
        if WinActive(target) {
            Send keyToSend
        } else {
            WinActivate target
            if WinWaitActive(target, , 1) {
                Sleep 50
                Send keyToSend
            }
        }
    } else {
        try {
            Run runPath
            if WinWait(target, , 5) {
                WinActivate target
                if WinWaitActive(target, , 2) {
                    Sleep 300
                    Send keyToSend
                }
            }
        } catch as err {
            MsgBox("アプリの起動に失敗しました:`n" . runPath, "Launch Error", 16)
        }
    }
}

/**
 * 最前面ならキー送信、そうでなければ前面化/起動のみ行う (Macの toggleAppOrSendKey 相当)
 */
ToggleAppOrSendKey(exeName, runPath, keyToSend) {
    target := "ahk_exe " . exeName
    if (runPath == "")
        runPath := exeName

    if WinExist(target) {
        if WinActive(target) {
            Send keyToSend
        } else {
            WinActivate target
        }
    } else {
        try {
            Run runPath
        } catch as err {
            MsgBox("アプリの起動に失敗しました:`n" . runPath, "Launch Error", 16)
        }
    }
}

/**
 * 登録名からアプリをトグル起動
 */
LaunchRegisteredApp(appName) {
    global APP_REGISTRY
    if (!APP_REGISTRY.Has(appName)) {
        MsgBox("未登録のアプリです: " . appName, "Error", 16)
        return
    }
    info := APP_REGISTRY[appName]
    ToggleApp(info[1], info[2])
}

/**
 * 登録名からキー付きでアプリをトグル起動
 */
LaunchRegisteredAppWithKey(appName, keyToSend) {
    global APP_REGISTRY
    if (!APP_REGISTRY.Has(appName)) {
        MsgBox("未登録のアプリです: " . appName, "Error", 16)
        return
    }
    info := APP_REGISTRY[appName]
    ToggleAppWithKey(info[1], info[2], keyToSend)
}
