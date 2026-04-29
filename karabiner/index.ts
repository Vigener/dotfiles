import {
    ifApp,
    ifInputSource,
    ifVar,
    map,
    rule,
    writeToProfile,
} from "karabiner.ts";

writeToProfile(
    {
        name: "Default profile",
    },
    [
        // =====================================================================
        // [APP_VIVALDI] Vivaldi専用マッピング
        // =====================================================================
        rule("【Vivaldi】英数+W/G で専用ショートカット起動").manipulators([
            // Vivaldiがアクティブな時のみ発火させる安全設計
            map("w", "optionalAny")
                .to("w", ["left_control", "left_option", "left_command"])
                .condition(
                    ifVar("eisuu_pressed", 1),
                    ifApp("^com\\.vivaldi\\.Vivaldi$"),
                ),
            map("g", "optionalAny")
                .to("g", ["left_control", "left_option", "left_command"])
                .condition(
                    ifVar("eisuu_pressed", 1),
                    ifApp("^com\\.vivaldi\\.Vivaldi$"),
                ),
        ]),

        // =====================================================================
        // [APP] Warp専用マッピング
        // =====================================================================
        rule(
            "【Warp】Ctrl+Opt+HJKL を Tmuxプレフィックス(Ctrl+B) + 矢印に変換",
        ).manipulators([
            map("h", ["left_control", "left_option"])
                .to("b", "left_control")
                .to("left_arrow")
                .condition(ifApp("^dev\\.warp\\.Warp-Stable$")),
            map("j", ["left_control", "left_option"])
                .to("b", "left_control")
                .to("down_arrow")
                .condition(ifApp("^dev\\.warp\\.Warp-Stable$")),
            map("k", ["left_control", "left_option"])
                .to("b", "left_control")
                .to("up_arrow")
                .condition(ifApp("^dev\\.warp\\.Warp-Stable$")),
            map("l", ["left_control", "left_option"])
                .to("b", "left_control")
                .to("right_arrow")
                .condition(ifApp("^dev\\.warp\\.Warp-Stable$")),
        ]),

        // =====================================================================
        // [SYS] コア・モディファイア設定
        // =====================================================================
        rule("【SYS】英数/かなキーをモディファイア化").manipulators([
            // CapsLockを左Optionとして利用
            map("caps_lock", "optionalAny").to("left_option"),

            // optionalAnyをつけることで、Shift等を押しながらでもフラグが立つようにする
            map("japanese_eisuu", "optionalAny")
                .to({ set_variable: { name: "eisuu_pressed", value: 1 } })
                .toAfterKeyUp({
                    set_variable: { name: "eisuu_pressed", value: 0 },
                })
                .toIfAlone("japanese_eisuu"),

            map("japanese_kana", "optionalAny")
                .to({ set_variable: { name: "kana_pressed", value: 1 } })
                .toAfterKeyUp({
                    set_variable: { name: "kana_pressed", value: 0 },
                })
                .toIfAlone("japanese_kana"),
        ]),

        // =====================================================================
        // [SYS] JIS配列補正
        // =====================================================================
        rule(
            "【SYS】ろキー(international1)をバックスラッシュに変換",
        ).manipulators([
            // 素押しはクリップボード経由で literal な backslash を貼り付ける
            // Shift+ろ(アンダーバー)はこのルールにマッチしないため、既定動作を維持する
            map("international1").to("international3", "left_option"),
        ]),

        // =====================================================================
        // [EDIT] 英数コンビネーション (移動・編集)
        // ※ 優先度を高くするため、WINDOW設定より必ず「上」に配置します
        // =====================================================================
        rule("【EDIT】英数レイヤー (カーソル移動・編集)").manipulators([
            // -------------------------------------------------------------
            // 1. 【例外ルール】 修飾キー(control等)を伴う特殊移動
            // ※Karabinerは上から評価するため、Anyより先に複合ルールを書く必要があります。
            // -------------------------------------------------------------

            // Winの「Alt+↑/↓ (行の入れ替え等)」を、Macの「Option+↑/↓」に翻訳
            // VSCode等での選択行の上下移動や、テキストエディタでの段落ジャンプとして機能します
            map("h", "left_option", "any")
                .to("left_arrow", "left_option")
                .condition(ifVar("eisuu_pressed", 1)),
            map("l", "left_option", "any")
                .to("right_arrow", "left_option")
                .condition(ifVar("eisuu_pressed", 1)),
            map("j", "left_option", "any")
                .to("down_arrow", "left_option")
                .condition(ifVar("eisuu_pressed", 1)),
            map("k", "left_option", "any")
                .to("up_arrow", "left_option")
                .condition(ifVar("eisuu_pressed", 1)),

            // Winの「Ctrl+←/→ (単語移動)」を、Macの「Option+←/→」に翻訳
            // (optionalAnyをつけることで、eisuu + control + shift + H で「単語選択」になる)
            map("h", "left_control", "any")
                .to("left_arrow", "left_option")
                .condition(ifVar("eisuu_pressed", 1)),
            map("l", "left_control", "any")
                .to("right_arrow", "left_option")
                .condition(ifVar("eisuu_pressed", 1)),
            // 高速スクロール: 1アクションで5行ずつ上下移動
            map("j", "left_control", "any")
                .to("down_arrow")
                .to("down_arrow")
                .to("down_arrow")
                .to("down_arrow")
                .to("down_arrow")
                .condition(ifVar("eisuu_pressed", 1)),
            map("k", "left_control", "any")
                .to("up_arrow")
                .to("up_arrow")
                .to("up_arrow")
                .to("up_arrow")
                .to("up_arrow")
                .condition(ifVar("eisuu_pressed", 1)),

            // Winの「Ctrl+Home/End (文頭・文末)」を、Macの「Cmd+↑/↓」に翻訳
            map("s", "left_control", "any")
                .to("up_arrow", "command")
                .condition(ifVar("eisuu_pressed", 1)),
            map("f", "left_control", "any")
                .to("down_arrow", "command")
                .condition(ifVar("eisuu_pressed", 1)),

            // Mac標準のOption+Deleteで「直前の単語を削除」
            map("o", "left_control", "any")
                .to("delete_or_backspace", "left_option")
                .condition(ifVar("eisuu_pressed", 1)),

            // VSCode: 英数+Control+B でセカンダリサイドバー開閉
            map("b", "left_control", "any")
                .to("b", ["left_command", "left_option"])
                .condition(ifVar("eisuu_pressed", 1)),

            // Mac標準のOption+ForwardDeleteで「次の単語を削除」
            map("open_bracket", "left_control", "any")
                .to("delete_forward", "left_option")
                .condition(ifVar("eisuu_pressed", 1)),

            // 英数+; を Enter に変換 (修飾キー付きも保持)
            map("semicolon", ["shift", "control", "option"])
                .to("return_or_enter", ["shift", "control", "option"])
                .condition(ifVar("eisuu_pressed", 1)),
            map("semicolon", ["shift", "control"])
                .to("return_or_enter", ["shift", "control"])
                .condition(ifVar("eisuu_pressed", 1)),
            map("semicolon", ["shift", "option"])
                .to("return_or_enter", ["shift", "option"])
                .condition(ifVar("eisuu_pressed", 1)),
            map("semicolon", ["control", "option"])
                .to("return_or_enter", ["control", "option"])
                .condition(ifVar("eisuu_pressed", 1)),
            map("semicolon", "shift")
                .to("return_or_enter", "shift")
                .condition(ifVar("eisuu_pressed", 1)),
            map("semicolon", "control")
                .to("return_or_enter", "control")
                .condition(ifVar("eisuu_pressed", 1)),
            map("semicolon", "option")
                .to("return_or_enter", "option")
                .condition(ifVar("eisuu_pressed", 1)),

            // -------------------------------------------------------------
            // 2. 【基本ルール】 通常の移動と操作 (optionalAny適用)
            // -------------------------------------------------------------

            // 基本のHJKL矢印
            map("h", "optionalAny")
                .to("left_arrow")
                .condition(ifVar("eisuu_pressed", 1)),
            map("j", "optionalAny")
                .to("down_arrow")
                .condition(ifVar("eisuu_pressed", 1)),
            map("k", "optionalAny")
                .to("up_arrow")
                .condition(ifVar("eisuu_pressed", 1)),
            map("l", "optionalAny")
                .to("right_arrow")
                .condition(ifVar("eisuu_pressed", 1)),

            // 行頭・行末 (Mac標準: Cmd+← / Cmd+→)
            map("s", "optionalAny")
                .to("left_arrow", "command")
                .condition(ifVar("eisuu_pressed", 1)),
            map("f", "optionalAny")
                .to("right_arrow", "command")
                .condition(ifVar("eisuu_pressed", 1)),

            // 編集系・その他
            map("o", "optionalAny")
                .to("delete_or_backspace")
                .condition(ifVar("eisuu_pressed", 1)),
            map("open_bracket", "optionalAny")
                .to("delete_forward")
                .condition(ifVar("eisuu_pressed", 1)),
            map("q", "optionalAny")
                .to("escape")
                .condition(ifVar("eisuu_pressed", 1)),
            // Mac標準のCmd+Spaceを発火させ、Raycastを起動する
            map("spacebar", "optionalAny")
                .to("spacebar", "command")
                .condition(ifVar("eisuu_pressed", 1)),

            // 【選択】「eisuu + d」の挙動
            // 行全体を選択する挙動(行頭移動 -> Shift+Cmd+→)を再現
            map("d", "optionalAny")
                .to("left_arrow", "command")
                .to("right_arrow", ["command", "shift"])
                .condition(ifVar("eisuu_pressed", 1)),

            // -------------------------------------------------------------
            // 3. 【Cmdショートカットの模倣】 (Macの主要Cmdショートカットを英数起点で発火)
            // ※ s, d, f, q, w は別機能のため除外済み
            // -------------------------------------------------------------
            map("z", "optionalAny")
                .to("z", "command")
                .condition(ifVar("eisuu_pressed", 1)), // Undo
            map("x", "optionalAny")
                .to("x", "command")
                .condition(ifVar("eisuu_pressed", 1)), // Cut
            map("c", "optionalAny")
                .to("c", "command")
                .condition(ifVar("eisuu_pressed", 1)), // Copy
            map("v", "optionalAny")
                .to("v", "command")
                .condition(ifVar("eisuu_pressed", 1)), // Paste
            map("n", "optionalAny")
                .to("n", "command")
                .condition(ifVar("eisuu_pressed", 1)), // New
            map("a", "optionalAny")
                .to("a", "command")
                .condition(ifVar("eisuu_pressed", 1)), // Select All
            map("e", "optionalAny")
                .to("e", "command")
                .condition(ifVar("eisuu_pressed", 1)), // Vivaldi Quick Command等
            map("r", "optionalAny")
                .to("r", "command")
                .condition(ifVar("eisuu_pressed", 1)), // Reload
            map("t", "optionalAny")
                .to("t", "command")
                .condition(ifVar("eisuu_pressed", 1)), // New Tab
            map("p", "optionalAny")
                .to("p", "command")
                .condition(ifVar("eisuu_pressed", 1)), // Print / Palette
            map("b", "optionalAny")
                .to("b", "command")
                .condition(ifVar("eisuu_pressed", 1)), // Toggle Primary Sidebar
            map("slash", "optionalAny")
                .to("slash", "command")
                .condition(ifVar("eisuu_pressed", 1)), // Toggle Comment

            // スクリーンショット系 (保存あり / クリップボードのみ)
            map("4", ["left_control", "left_shift"], "any")
                .to("4", ["left_command", "left_shift", "left_control"])
                .condition(ifVar("eisuu_pressed", 1)),
            map("4", "left_shift", "any")
                .to("4", ["left_command", "left_shift"])
                .condition(ifVar("eisuu_pressed", 1)),
            map("3", ["left_control", "left_shift"], "any")
                .to("3", ["left_command", "left_shift", "left_control"])
                .condition(ifVar("eisuu_pressed", 1)),
            map("3", "left_shift", "any")
                .to("3", ["left_command", "left_shift"])
                .condition(ifVar("eisuu_pressed", 1)),
        ]),

        // =====================================================================
        // [WINDOW] タブ・ウィンドウ操作 (グローバル)
        // ※ 英数レイヤーの「下」に配置することで、英数非押下時のみ発火させます
        // =====================================================================
        rule("【WINDOW】タブを閉じる (Ctrl+Q)").manipulators([
            // Mac標準のCtrl+W(単語削除)を汚さず、左手のみでタブ(Cmd+W)を閉じる
            map("q", "left_control").to("w", "command"),
        ]),

        rule(
            "【WINDOW】Option + HJKL (Mac標準のウィンドウ/スペース操作へマッピング)",
        ).manipulators([
            map("j", "left_option").to("h", "command"), // Mac非表示
            map("k", ["left_option", "shift"]).to("f", ["control", "command"]), // フルスクリーン (Ctrl+Cmd+F) ただし、これだけRaycastのMaximizeとの兼ね合いでShiftも必要とする
            map("h", "left_option").to("left_arrow", "control"), // 左のスペースへ移動 (Ctrl+←)
            map("l", "left_option").to("right_arrow", "control"), // 右のスペースへ移動 (Ctrl+→)
        ]),

        // RaycastのWindows Management用テンプレート
        // 注意: ここに書いたショートカットは、RaycastのWindows Managementのショートカットと完全に一致させる必要があります。
        rule("【WINDOW】Raycast Windows Management (template)").manipulators([
            // Option+, でウィンドウを左半分に配置(Cmd+Opt+Control+←)
            // (他での役割が出るまで)英数+,でも発火するようにする
            map("comma", "option").to("left_arrow", [
                "left_command",
                "left_option",
                "left_control",
            ]),
            map("comma", "optionalAny")
                .to("left_arrow", [
                    "left_command",
                    "left_option",
                    "left_control",
                ])
                .condition(ifVar("eisuu_pressed", 1)),
            // Option+. でウィンドウを右半分に配置(Cmd+Opt+Control+→)
            // (他での役割が出るまで)英数+.でも発火するようにする
            map("period", "option").to("right_arrow", [
                "left_command",
                "left_option",
                "left_control",
            ]),
            map("period", "optionalAny")
                .to("right_arrow", [
                    "left_command",
                    "left_option",
                    "left_control",
                ])
                .condition(ifVar("eisuu_pressed", 1)),
            // Option+kでウィンドウを最大化(Cmd+Opt+Control+F)
            map("k", "left_option").to("f", [
                "left_command",
                "left_option",
                "left_control",
            ]),
            // Option+nでNext Displayへ移動(Cmd+Opt+Control+n)
            map("n", "option").to("n", [
                "left_command",
                "left_option",
                "left_control",
            ]),
        ]),
        // =====================================================================
        // [APP] かなコンビネーション (メディア操作・アプリ起動)
        // =====================================================================
        rule("【APP】かなレイヤー (アプリ起動・メディア操作)").manipulators([
            // -------------------------------------------------------------
            // メディア操作
            // -------------------------------------------------------------
            map("h", "optionalAny")
                .to("play_or_pause")
                .condition(ifVar("kana_pressed", 1)),
            map("u", "optionalAny")
                .to("volume_up")
                .condition(ifVar("kana_pressed", 1)),
            map("i", "optionalAny")
                .to("volume_down")
                .condition(ifVar("kana_pressed", 1)),
            map("y", "optionalAny")
                .to("mute")
                .condition(ifVar("kana_pressed", 1)),

            // -------------------------------------------------------------
            // アプリ起動
            // -------------------------------------------------------------
            map("m", "optionalAny")
                .toApp("Visual Studio Code")
                .condition(ifVar("kana_pressed", 1)),
            map("s", "optionalAny")
                .toApp("Slack")
                .condition(ifVar("kana_pressed", 1)),
            map("k", "optionalAny")
                .toApp("Karabiner-Elements")
                .condition(ifVar("kana_pressed", 1)),
            // map("t", "optionalAny")
            //     .toApp("Terminal")
            //     .condition(ifVar("kana_pressed", 1)),
            map("w", "optionalAny")
                .toApp("Warp")
                .condition(ifVar("kana_pressed", 1)),
            map("e", "optionalAny")
                .toApp("Mail")
                .condition(ifVar("kana_pressed", 1)),
            map("b", "optionalAny")
                .toApp("Bitwarden")
                .condition(ifVar("kana_pressed", 1)),
            map("f", "optionalAny")
                .toApp("Finder")
                .condition(ifVar("kana_pressed", 1)),
            map("p", "optionalAny") // powerpoint
                .toApp("Microsoft PowerPoint")
                .condition(ifVar("kana_pressed", 1)),
            map("z", "optionalAny") // zoom
                .toApp("zoom.us")
                .condition(ifVar("kana_pressed", 1)),

            // Vivaldi PWA
            //  Notion(PWA in Vivaldi)の絶対パス起動
            map("n", "optionalAny")
                .to$(
                    `open '/Users/mikoto/Applications/Vivaldi Apps.localized/Notion.app'`,
                )
                .condition(ifVar("kana_pressed", 1)),
            // GoogleCalendar(PWA in Vivaldi)の絶対パス起動
            map("c", "optionalAny")
                .to$(
                    `open '/Users/mikoto/Applications/Vivaldi Apps.localized/GoogleCalendar.app'`,
                )
                .condition(ifVar("kana_pressed", 1)),
            // Gemini(PWA in Vivaldi)の絶対パス起動
            map("g", "optionalAny")
                .to$(
                    `open '/Users/mikoto/Applications/Vivaldi Apps.localized/Gemini.app'`,
                )
                .condition(ifVar("kana_pressed", 1)),

            // Vivaldiは特殊構造のためBundle IDで強制起動
            map("v", "optionalAny")
                .to$(`open -b com.vivaldi.Vivaldi`)
                .condition(ifVar("kana_pressed", 1)),
        ]),

        // =====================================================================
        // [AZIK] 日本語入力時カスタム (長音・促音・頻出単語)
        // =====================================================================
        rule("【AZIK】セミコロンで促音(っ)、コロンで長音(ー)").manipulators([
            // USキーボードのコロンの位置を想定
            map("quote")
                .to("hyphen")
                .condition(ifInputSource({ language: "ja" })),
            // セミコロンを「x, t, u」の3ストロークに変換
            map("semicolon")
                .to("x")
                .to("t")
                .to("u")
                .condition(ifInputSource({ language: "ja" })),
        ]),
    ],
);
