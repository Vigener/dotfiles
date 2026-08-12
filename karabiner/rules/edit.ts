import { ifVar, map, rule } from "karabiner.ts";

export const editRules = [
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

    // 英数+Shift+Enter → Cmd+Shift+Enter（optionalAny より先に評価し、Raycast モードの Enter 解除と干渉しない）
    map("return_or_enter", "left_shift", "any")
      .to("return_or_enter", ["left_command", "left_shift"])
      .condition(ifVar("eisuu_pressed", 1)),
    map("return_or_enter", "right_shift", "any")
      .to("return_or_enter", ["left_command", "left_shift"])
      .condition(ifVar("eisuu_pressed", 1)),

    // Mac標準のOption+ForwardDeleteで「次の単語を削除」
    // JIS実機 (EventViewer): @ = open_bracket
    map("open_bracket", "left_control", "any")
      .to("delete_forward", "left_option")
      .condition(ifVar("eisuu_pressed", 1)),

    // 英数+Ctrl+[ / ] → Cmd+Ctrl+[ / ]
    // JIS実機 (EventViewer): [ = close_bracket, ] = non_us_pound
    map("close_bracket", "left_control", "any")
      .to("close_bracket", ["left_command", "left_control"])
      .condition(ifVar("eisuu_pressed", 1)),
    map("non_us_pound", "left_control", "any")
      .to("non_us_pound", ["left_command", "left_control"])
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
    map("k", "optionalAny").to("up_arrow").condition(ifVar("eisuu_pressed", 1)),
    map("l", "optionalAny")
      .to("right_arrow")
      .condition(ifVar("eisuu_pressed", 1)),

    // 行頭・行末 (Mac標準: Cmd+← / Cmd+→)
    // 視覚的な折り返し行に対応するため、Emacsバインド(Ctrl+A/E)ではなくこちらを採用
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
    // JIS: @ = open_bracket → Forward Delete（カーソル右側を1文字削除）
    map("open_bracket", "optionalAny")
      .to("delete_forward")
      .condition(ifVar("eisuu_pressed", 1)),
    map("q", "optionalAny").to("escape").condition(ifVar("eisuu_pressed", 1)),
    // 英数+; → Enter（物理修飾キーは押したまま残るので Shift+Enter 等も可）
    map("semicolon", "optionalAny")
      .to("return_or_enter")
      .condition(ifVar("eisuu_pressed", 1)),
    // Mac標準のCmd+Spaceを発火させ、Raycastを起動する
    map("spacebar", "optionalAny")
      .to("spacebar", "command")
      .condition(ifVar("eisuu_pressed", 1)),

    // 【選択】「eisuu + d」の挙動
    // 視覚的な折り返し行に対応するため、Cmd+← -> Shift+Cmd+→ (行頭移動 -> 行末まで選択) を採用
    map("d", "optionalAny")
      .to("left_arrow", "command")
      .to("right_arrow", ["command", "shift"])
      .condition(ifVar("eisuu_pressed", 1)),

    // -------------------------------------------------------------
    // 3. 【Cmdショートカットの模倣】 (Macの主要Cmdショートカットを英数起点で発火)
    // ※ s, d, f, q は別機能のため除外済み
    // -------------------------------------------------------------
    map("w", "optionalAny")
      .to("w", "command")
      .condition(ifVar("eisuu_pressed", 1)), // Close Tab/Window
    map("z", "optionalAny")
      .to("z", "command")
      .condition(ifVar("eisuu_pressed", 1)), // Undo
    map("y", "optionalAny")
      .to("y", "command")
      .condition(ifVar("eisuu_pressed", 1)), // Redo / History
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
    map("g", "optionalAny")
      .to("g", "command")
      .condition(ifVar("eisuu_pressed", 1)), // Find Next等
    map("r", "optionalAny")
      .to("r", "command")
      .condition(ifVar("eisuu_pressed", 1)), // Reload
    map("t", "left_control", "any")
      .to("t", ["left_command", "left_option"])
      .condition(ifVar("eisuu_pressed", 1)), // New Tab in Group
    map("t", "optionalAny")
      .to("t", "command")
      .condition(ifVar("eisuu_pressed", 1)), // New Tab
    map("p", "optionalAny")
      .to("p", "command")
      .condition(ifVar("eisuu_pressed", 1)), // Print / Palette
    map("b", "optionalAny")
      .to("b", "command")
      .condition(ifVar("eisuu_pressed", 1)), // Toggle Primary Sidebar
    map("u", "optionalAny")
      .to("u", "command")
      .condition(ifVar("eisuu_pressed", 1)), // Underline / Cmd+U
    // JIS: [ = close_bracket, ] = non_us_pound（ANSI名とは一致しない）
    map("close_bracket", "optionalAny")
      .to("close_bracket", "command")
      .condition(ifVar("eisuu_pressed", 1)), // Cmd+[（戻る等）
    map("non_us_pound", "optionalAny")
      .to("non_us_pound", "command")
      .condition(ifVar("eisuu_pressed", 1)), // Cmd+]（進む等）
    map("slash", "optionalAny")
      .to("slash", "command")
      .condition(ifVar("eisuu_pressed", 1)), // Toggle Comment

    // スクリーンショット系 (保存あり / クリップボードのみ)
    // ※ 英数+1..9 より先に置く（Shift+3/4 が agent focus に吸われないように）
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

    // herdr focus_agent (ctrl+alt+1..9)。pane 系の直バインドと同系の出力に寄せる
    ...(["1", "2", "3", "4", "5", "6", "7", "8", "9"] as const).map((n) =>
      map(n, "optionalAny")
        .to(n, ["left_control", "left_option"])
        .condition(ifVar("eisuu_pressed", 1)),
    ),
  ]),
];
