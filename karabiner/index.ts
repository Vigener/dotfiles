import { ifVar, map, rule, writeToProfile } from "karabiner.ts";

import * as path from "path";

// sample code for karabiner.ts
// writeToProfile("Default", [
//     // 1 profile to config complex_modifications
//     rule("Demo Rule") // 2 rules
//         .manipulators([
//             // 3 manipulators
//             map("⇪") // 4 from
//                 .to("⌫", "⌘") // 5 to
//                 .condition(ifVar("test")), // 6 conditions
//         ]),
// ]);

// 第1引数でプロファイル名と、書き出し先のJSONファイルパス（このファイルと同じディレクトリ）を指定します
writeToProfile(
    {
        name: "Default profile",
        karabinerJsonPath: path.resolve("karabiner.json"),
    },
    // "--dry-run",
    [
        // ---------------------------------------------------------
        // [SYS] コア・モディファイア設定
        // ---------------------------------------------------------
        rule("英数/かなキーをモディファイア化").manipulators([
            // 英数キー: 単押しで英数、他キーと同時押しで eisuu_pressed=1
            map("japanese_eisuu")
                .to({ set_variable: { name: "eisuu_pressed", value: 1 } })
                .toAfterKeyUp({
                    set_variable: { name: "eisuu_pressed", value: 0 },
                })
                .toIfAlone("japanese_eisuu"),

            // かなキー: 単押しでかな、他キーと同時押しで kana_pressed=1
            map("japanese_kana")
                .to({ set_variable: { name: "kana_pressed", value: 1 } })
                .toAfterKeyUp({
                    set_variable: { name: "kana_pressed", value: 0 },
                })
                .toIfAlone("japanese_kana"),
        ]),

        // ---------------------------------------------------------
        // [WINDOW] タブ・ウィンドウ操作
        // ---------------------------------------------------------
        rule("タブを閉じる (Ctrl+Q)").manipulators([
            // 第一案: Mac標準のCtrl+Wを汚さず、Ctrl+Qでタブを閉じる(Cmd+W)
            map("q", "left_control").to("w", "command"),
        ]),

        // ---------------------------------------------------------
        // [TEST] テスト用追加ルール（変更確認用）
        // ---------------------------------------------------------
        rule("【テスト】かなコンビネーション (Warp起動)").manipulators([
            // kana_pressed が 1 の状態のときだけ発火
            map("p").toApp("Warp").condition(ifVar("kana_pressed", 1)),
        ]),
    ],
);
