import { ifApp, ifVar, map, rule } from "karabiner.ts";

export const appRules = [
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
    map("t", ["left_control", "left_shift"]).to("t", [
      "left_command",
      "left_shift",
    ]),
    map("t", ["left_control"]).to("t", ["left_command"]),
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
];
