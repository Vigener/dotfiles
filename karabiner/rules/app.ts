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
  // 基準ジャンプと左右移動（左手 Alt）。Opt+E は ABC のアキュート・デッドキーなので使わない。
  // Q=左 / W=基準 / R=右。Ghostty・ブラウザ・Cursor・Slack が前面のときだけ。
  // =====================================================================
  rule("【Ghostty】左Alt+Q/W/R で herdr の基準・前・次").manipulators([
    map("q", "left_option")
      .to("1", ["left_control", "left_option"])
      .condition(ifApp("^com\\.mitchellh\\.ghostty$")),
    map("w", "left_option")
      .to("spacebar", "left_control")
      .to("comma")
      .condition(ifApp("^com\\.mitchellh\\.ghostty$")),
    map("r", "left_option")
      .to("spacebar", "left_control")
      .to("period")
      .condition(ifApp("^com\\.mitchellh\\.ghostty$")),
  ]),

  rule("【ブラウザ】左Alt+Q/W/R で先頭タブ・前のタブ・次のタブ").manipulators([
    map("q", "left_option")
      .to("1", "left_command")
      .condition(
        ifApp([
          "^com\\.vivaldi\\.Vivaldi$",
          "^com\\.google\\.Chrome$",
          "^app\\.zen-browser\\.zen$",
          "^company\\.thebrowser\\.dia$",
        ]),
      ),
    map("w", "left_option")
      .to("close_bracket", ["left_command", "left_shift"])
      .condition(
        ifApp([
          "^com\\.vivaldi\\.Vivaldi$",
          "^com\\.google\\.Chrome$",
          "^app\\.zen-browser\\.zen$",
          "^company\\.thebrowser\\.dia$",
        ]),
      ),
    map("r", "left_option")
      .to("non_us_pound", ["left_command", "left_shift"])
      .condition(
        ifApp([
          "^com\\.vivaldi\\.Vivaldi$",
          "^com\\.google\\.Chrome$",
          "^app\\.zen-browser\\.zen$",
          "^company\\.thebrowser\\.dia$",
        ]),
      ),
  ]),

  rule("【Cursor/VSCode】左Alt+Q/W/R で第1グループ・前のタブ・次のタブ").manipulators([
    map("q", "left_option")
      .to("1", "left_command")
      .condition(
        ifApp([
          "^com\\.todesktop\\.230313mzl4w4u92$",
          "^com\\.microsoft\\.VSCode$",
        ]),
      ),
    map("w", "left_option")
      .to("close_bracket", ["left_command", "left_shift"])
      .condition(
        ifApp([
          "^com\\.todesktop\\.230313mzl4w4u92$",
          "^com\\.microsoft\\.VSCode$",
        ]),
      ),
    map("r", "left_option")
      .to("non_us_pound", ["left_command", "left_shift"])
      .condition(
        ifApp([
          "^com\\.todesktop\\.230313mzl4w4u92$",
          "^com\\.microsoft\\.VSCode$",
        ]),
      ),
  ]),

  rule("【Slack】左Alt+Q/W/R で未読一覧・前の未読・次の未読").manipulators([
    map("q", "left_option")
      .to("a", ["left_command", "left_shift"])
      .condition(ifApp("^com\\.tinyspeck\\.slackmacgap$")),
    map("w", "left_option")
      .to("up_arrow", ["left_option", "left_shift"])
      .condition(ifApp("^com\\.tinyspeck\\.slackmacgap$")),
    map("r", "left_option")
      .to("down_arrow", ["left_option", "left_shift"])
      .condition(ifApp("^com\\.tinyspeck\\.slackmacgap$")),
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
