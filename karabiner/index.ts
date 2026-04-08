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
        karabinerJsonPath: new URL("./karabiner.json", import.meta.url)
            .pathname,
    },
    [
        // =====================================================================
        // [JA] 日本語入力のカスタマイズ
        // =====================================================================
        rule(
            "【JA】日本語入力時: セミコロンで促音(っ)、コロンで長音(ー)",
        ).manipulators([
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
        // [WINDOW] タブ・ウィンドウ操作 (グローバル)
        // =====================================================================
        rule("【WINDOW】タブを閉じる (Ctrl+Q)").manipulators([
            // Mac標準のCtrl+W(単語削除)を汚さず、左手のみでタブ(Cmd+W)を閉じる
            map("q", "left_control").to("w", "command"),
        ]),

        rule(
            "【WINDOW】Option + HJKL (Mac標準のウィンドウ/スペース操作へマッピング)",
        ).manipulators([
            map("j", "left_option").to("m", "command"), // 最小化 (Cmd+M)
            map("k", "left_option").to("f", ["control", "command"]), // フルスクリーン (Ctrl+Cmd+F)
            map("h", "left_option").to("left_arrow", "control"), // 左のスペースへ移動 (Ctrl+←)
            map("l", "left_option").to("right_arrow", "control"), // 右のスペースへ移動 (Ctrl+→)
        ]),

        // =====================================================================
        // [EDIT] 英数コンビネーション (移動・編集)
        // =====================================================================
        rule("【EDIT】英数レイヤー (カーソル移動・編集)").manipulators([
            // -------------------------------------------------------------
            // 1. 【例外ルール】 修飾キー(control等)を伴う特殊移動
            // ※Karabinerは上から評価するため、Anyより先に複合ルールを書く必要があります。
            // -------------------------------------------------------------

            // Winの「Ctrl+←/→ (単語移動)」を、Macの「Option+←/→」に翻訳
            // (optionalAnyをつけることで、eisuu + control + shift + H で「単語選択」になる)
            map("h", "left_control", "any")
                .to("left_arrow", "left_option")
                .condition(ifVar("eisuu_pressed", 1)),
            map("l", "left_control", "any")
                .to("right_arrow", "left_option")
                .condition(ifVar("eisuu_pressed", 1)),
            map("j", "left_control", "any")
                .to("down_arrow", "left_option")
                .condition(ifVar("eisuu_pressed", 1)), // Option+Downは段落移動
            map("k", "left_control", "any")
                .to("up_arrow", "left_option")
                .condition(ifVar("eisuu_pressed", 1)),

            // Winの「Ctrl+Home/End (文頭・文末)」を、Macの「Cmd+↑/↓」に翻訳
            map("s", "left_control", "any")
                .to("up_arrow", "command")
                .condition(ifVar("eisuu_pressed", 1)),
            map("f", "left_control", "any")
                .to("down_arrow", "command")
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
            map("spacebar", "optionalAny")
                .to("return_or_enter")
                .condition(ifVar("eisuu_pressed", 1)),

            // 【選択】「eisuu + d」の挙動
            // 行全体を選択する挙動(行頭移動 -> Shift+Cmd+→)を再現
            map("d", "optionalAny")
                .to("left_arrow", "command")
                .to("right_arrow", ["command", "shift"])
                .condition(ifVar("eisuu_pressed", 1)),

            // Cmdショートカットの模倣
            map("p", "optionalAny")
                .to("p", "command")
                .condition(ifVar("eisuu_pressed", 1)),
            map("c", "optionalAny")
                .to("c", "command")
                .condition(ifVar("eisuu_pressed", 1)),
            map("v", "optionalAny")
                .to("v", "command")
                .condition(ifVar("eisuu_pressed", 1)),
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
            map("t", "optionalAny")
                .toApp("Terminal")
                .condition(ifVar("kana_pressed", 1)),
            map("p", "optionalAny")
                .toApp("Warp")
                .condition(ifVar("kana_pressed", 1)),
            map("e", "optionalAny")
                .toApp("Mail")
                .condition(ifVar("kana_pressed", 1)),
            map("b", "optionalAny")
                .toApp("Bitwarden")
                .condition(ifVar("kana_pressed", 1)),
            map("c", "optionalAny")
                .toApp("Calendar")
                .condition(ifVar("kana_pressed", 1)),

            // Vivaldiは特殊構造のためBundle IDで強制起動
            map("v", "optionalAny")
                .to$(`open -b com.vivaldi.Vivaldi`)
                .condition(ifVar("kana_pressed", 1)),

            // (nは空になっていたため無効化。必要に応じて追記してください)
            // map("n", "optionalAny").toApp("Notion").condition(ifVar("kana_pressed", 1)),
        ]),
    ],
);
