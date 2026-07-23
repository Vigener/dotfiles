import { ifApp, ifVar, map, rule } from "karabiner.ts";

// =====================================================================
// 🛡️ 条件定義: RaycastのSwitch Windowsモード中であること
// =====================================================================
// Raycastが前面にある時のみ発火させることで、変数が残り続けた際の暴発を完全に防ぐ
const ifRaycastMode = [
  ifVar("raycast_window_mode", 1),
  ifApp("^com\\.raycast\\.macos$"),
];

export const windowRules = [
  // =====================================================================
  // [WINDOW] タブ・ウィンドウ操作 (グローバル)
  // ※ Ctrl+Q (Cmd+W) は Zellij と干渉するため廃止
  // =====================================================================


  // =====================================================================
  // [WINDOW] かなレイヤー (ウィンドウマネジメント・スペース移動)
  // =====================================================================
  rule("【WINDOW】かなレイヤー (Raycast & Mac標準ウィンドウ操作)").manipulators(
    [
      // -------...---------
      // 1. デスクトップ空間（Spaces）とウィンドウ状態の操作
      // -------...---------
      map("h", "optionalAny")
        .to("left_arrow", "control")
        .condition(ifVar("kana_pressed", 1)), // 左のスペース
      map("l", "optionalAny")
        .to("right_arrow", "control")
        .condition(ifVar("kana_pressed", 1)), // 右のスペース
      map("j", "optionalAny")
        .to("m", "command")
        .condition(ifVar("kana_pressed", 1)), // 最小化 (Cmd+M)
      map("k", "optionalAny")
        .to("f", ["control", "command"])
        .condition(ifVar("kana_pressed", 1)), // フルスクリーン
      map("k", ["shift"])
        .to("f", ["left_control", "left_option", "left_command"])
        .condition(ifVar("kana_pressed", 1)),

      // -------...---------
      // 2. 画面内でのウィンドウリサイズ (Raycast連携: Ctrl+Opt+Cmd)
      // -------...---------
      // 左半分
      map("comma", "optionalAny")
        .to("left_arrow", ["left_control", "left_option", "left_command"])
        .condition(ifVar("kana_pressed", 1)),
      // 右半分
      map("period", "optionalAny")
        .to("right_arrow", ["left_control", "left_option", "left_command"])
        .condition(ifVar("kana_pressed", 1)),
      // ほぼ最大化(Cmd+Opt+Control+F)
      map("slash", "optionalAny")
        .to("f", ["left_control", "left_option", "left_command"])
        .condition(ifVar("kana_pressed", 1)),
      // 完全最大化 (Shift追加)(Cmd+Control+F)
      map("slash", ["left_shift"])
        .to("f", ["left_control", "left_command"])
        .condition(ifVar("kana_pressed", 1)),
      // Next Display (backslash)(Cmd+Opt+Control+n)
      map("international1", "optionalAny")
        .to("n", ["left_control", "left_option", "left_command"])
        .condition(ifVar("kana_pressed", 1)),
      // Switch Display Preset (Raycast Display Placer: Cmd+Opt+Ctrl+Shift+d)
      map("d", "optionalAny")
        .to("d", ["left_control", "left_option", "left_command", "left_shift"])
        .condition(ifVar("kana_pressed", 1)),
      // Mission Control (Ctrl+Up)
      map("semicolon", "optionalAny")
        .to("up_arrow", "control")
        .condition(ifVar("kana_pressed", 1)),
      // Reasonable Size (Cmd+Opt+Control+r)
      // map(";", "optionalAny")
      //   .to("r", ["left_control", "left_option", "left_command"])
      //   .condition(ifVar("kana_pressed", 1)),

      // -------...---------
      // 3. アプリ自体の切り替え(RaycastのSwitch Windows連携)
      // -------...---------
      // `Cmd+Option+Tab`に割り当てているので、同じショートカットを「かな+right_cmd」および「英数+Tab」で発火させる
      // 同時にRaycast操作用の変数を1(ON)にする
      map("right_command", "optionalAny")
        .to("tab", ["left_command", "left_option"])
        .toVar("raycast_window_mode", 1)
        .condition(ifVar("kana_pressed", 1)),
      map("tab", "optionalAny")
        .to("tab", ["left_command", "left_option"])
        .toVar("raycast_window_mode", 1)
        .condition(ifVar("eisuu_pressed", 1)),

      // ======= Raycast Switch Windows モード中の Vim風キーバインド =======
      // ※ 修飾キーなしの単押しのみ許可し、予期せぬ暴発を防ぐ
      map("j")
        .to("down_arrow")
        .condition(...ifRaycastMode),
      map("k")
        .to("up_arrow")
        .condition(...ifRaycastMode),

      // アクションメニューの展開 (Space で Cmd+K を代行)
      map("spacebar")
        .to("k", "left_command")
        .condition(...ifRaycastMode),

      // ウィンドウアクションの単押しショートカット化
      map("m")
        .to("m", "left_command")
        .condition(...ifRaycastMode), // 最小化
      map("f")
        .to("f", "left_command")
        .condition(...ifRaycastMode), // フルスクリーン
      map("w")
        .to("w", ["left_command", "left_shift"])
        .condition(...ifRaycastMode), // 閉じる
      map("h")
        .to("h", "left_command")
        .condition(...ifRaycastMode), // 隠す

      // ======= モードの解除 =======
      // 選択決定、またはキャンセル時にフラグをリセットし、本来のキーを送信する
      map("return_or_enter", "optionalAny")
        .to("return_or_enter")
        .toVar("raycast_window_mode", 0)
        .condition(...ifRaycastMode),

      map("escape", "optionalAny")
        .to("escape")
        .toVar("raycast_window_mode", 0)
        .condition(...ifRaycastMode),
    ],
  ),

  // =====================================================================
  // 【WINDOW】Raycast Windows Management (template)
  // =====================================================================
  rule("【WINDOW】Raycast Windows Management (template)").manipulators([
    // Option+, でウィンドウを左半分に配置(Cmd+Opt+Control+←)
    // (他での役割が出るまで)英数+,でも発火するようにする
    map("comma", "option").to("left_arrow", [
      "left_command",
      "left_option",
      "left_control",
    ]),
    map("comma", "optionalAny")
      .to("left_arrow", ["left_command", "left_option", "left_control"])
      .condition(ifVar("eisuu_pressed", 1)),
    // Option+. でウィンドウを右半分に配置(Cmd+Opt+Control+→)
    // (他での役割が出るまで)英数+.でも発火するようにする
    map("period", "option").to("right_arrow", [
      "left_command",
      "left_option",
      "left_control",
    ]),
    map("period", "optionalAny")
      .to("right_arrow", ["left_command", "left_option", "left_control"])
      .condition(ifVar("eisuu_pressed", 1)),
    // Option+kでウィンドウを最大化(Cmd+Opt+Control+F)
    map("k", "left_option").to("f", [
      "left_command",
      "left_option",
      "left_control",
    ]),
    // Option+nでNext Displayへ移動(Cmd+Opt+Control+n)
    // map("n", "option").to("n", ["left_command", "left_option", "left_control"]),
  ]),
];
