import { ifVar, map, rule } from "karabiner.ts";

export const windowRules = [
  // =====================================================================
  // [WINDOW] タブ・ウィンドウ操作 (グローバル)
  // ※ 英数レイヤーの「下」に配置することで、英数非押下時のみ発火させます
  // =====================================================================
  rule("【WINDOW】タブを閉じる (Ctrl+Q)").manipulators([
    // Mac標準のCtrl+W(単語削除)を汚さず、左手のみでタブ(Cmd+W)を閉じる
    map("q", "left_control").to("w", "command"),
  ]),

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
        .to("h", "command")
        .condition(ifVar("kana_pressed", 1)), // 隠す (Cmd+H)
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
      // Reasonable Size (Cmd+Opt+Control+r)
      map(";", "optionalAny")
        .to("r", ["left_control", "left_option", "left_command"])
        .condition(ifVar("kana_pressed", 1)),

      // -------...---------
      // 3. アプリ自体の切り替え(RaycastのSwitch Windowsと同じショートカットを想定)
      // -------...---------
      //現在は、`Cmd+Option+Tab`に割り当てているので、同じショートカットを「かな+right_cmd」で発火させる
      map("right_command", "optionalAny")
        .to("tab", ["left_command", "left_option"])
        .condition(ifVar("kana_pressed", 1)),
    ],
  ),

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
    map("n", "option").to("n", ["left_command", "left_option", "left_control"]),
  ]),
];
