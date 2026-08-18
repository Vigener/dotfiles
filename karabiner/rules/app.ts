import { ifApp, ifVar, map, rule } from "karabiner.ts";

const CMUX = "^com\\.cmuxterm\\.app$";

export const appRules = [
  // =====================================================================
  // [APP_CMUX] Cmux 前景のみ: Cmd+T / 英数+T → herdr new_tab (prefix+c)
  // Ghostty は cmd+t=text:\x00c。Cmux はアプリが Cmd+T を飲むので
  // Karabiner が ctrl+space, c を直送する。試用。他アプリの英数+T は Cmd+T のまま。
  // appRules が edit.ts より先なので、英数+T は Cmd+T に化ける前にここで消費する。
  // =====================================================================
  rule("【Cmux】Cmd+T / 英数+T で herdr 新規タブ").manipulators([
    map("t", "optionalAny")
      .to("spacebar", "left_control")
      .to("c")
      .condition(ifVar("eisuu_pressed", 1), ifApp(CMUX)),
    map("t", "command")
      .to("spacebar", "left_control")
      .to("c")
      .condition(ifApp(CMUX)),
  ]),

  // =====================================================================
  // [APP_VIVALDI] Vivaldi専用マッピング
  // =====================================================================
  rule("【Vivaldi】英数+W/G で専用ショートカット起動").manipulators([
    // Vivaldiがアクティブな時のみ発火させる安全設計
    map("w", "optionalAny")
      .to("w", ["left_control", "left_option", "left_command"])
      .condition(ifVar("eisuu_pressed", 1), ifApp("^com\\.vivaldi\\.Vivaldi$")),
    map("g", "optionalAny")
      .to("g", ["left_control", "left_option", "left_command"])
      .condition(ifVar("eisuu_pressed", 1), ifApp("^com\\.vivaldi\\.Vivaldi$")),
  ]),

  // =====================================================================
  // [APP_GHOSTTY] Ghostty + herdr（英数+Ctrl を herdr の ctrl+alt 直叩きへ）
  // EDIT の英数+Ctrl+HJKL（単語/スクロール）より先に評価されるよう appRules 先頭側に置く
  // 英数+Ctrl+Q は EDIT の英数+Q=Esc に吸われるので、Ghostty では Ctrl+Q のまま通す
  // （Ghostty 側が prefix+q / デタッチにジャック。Cmd+Q は触らない）
  // =====================================================================
  rule(
    "【Ghostty】英数+Ctrl+HJKL/V/-/Q/D を herdr 向けに変換",
  ).manipulators([
    map("d", "left_control", "any")
      .to("d", ["left_control", "left_option"])
      .condition(
        ifVar("eisuu_pressed", 1),
        ifApp("^com\\.mitchellh\\.ghostty$"),
      ),
    map("q", "left_control", "any")
      .to("q", "left_control")
      .condition(
        ifVar("eisuu_pressed", 1),
        ifApp("^com\\.mitchellh\\.ghostty$"),
      ),
    map("h", "left_control", "any")
      .to("h", ["left_control", "left_option"])
      .condition(
        ifVar("eisuu_pressed", 1),
        ifApp("^com\\.mitchellh\\.ghostty$"),
      ),
    map("j", "left_control", "any")
      .to("j", ["left_control", "left_option"])
      .condition(
        ifVar("eisuu_pressed", 1),
        ifApp("^com\\.mitchellh\\.ghostty$"),
      ),
    map("k", "left_control", "any")
      .to("k", ["left_control", "left_option"])
      .condition(
        ifVar("eisuu_pressed", 1),
        ifApp("^com\\.mitchellh\\.ghostty$"),
      ),
    map("l", "left_control", "any")
      .to("l", ["left_control", "left_option"])
      .condition(
        ifVar("eisuu_pressed", 1),
        ifApp("^com\\.mitchellh\\.ghostty$"),
      ),
    map("v", "left_control", "any")
      .to("v", ["left_control", "left_option"])
      .condition(
        ifVar("eisuu_pressed", 1),
        ifApp("^com\\.mitchellh\\.ghostty$"),
      ),
    map("hyphen", "left_control", "any")
      .to("hyphen", ["left_control", "left_option"])
      .condition(
        ifVar("eisuu_pressed", 1),
        ifApp("^com\\.mitchellh\\.ghostty$"),
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
  // [APP_PREVIEW] Preview専用マッピング
  // =====================================================================
  // rule("【Preview】j/k を上下矢印にマッピング").manipulators([
  //   map("j").to("down_arrow").condition(ifApp("^com\\.apple\\.Preview$")),
  //   map("k").to("up_arrow").condition(ifApp("^com\\.apple\\.Preview$")),
  //   map("h").to("left_arrow").condition(ifApp("^com\\.apple\\.Preview$")),
  //   map("l").to("right_arrow").condition(ifApp("^com\\.apple\\.Preview$")),
  // ]),
];
