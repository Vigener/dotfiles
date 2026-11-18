import { ifDevice, ifVar, map, mapPointingButton, rule } from "karabiner.ts";

// =====================================================================
// [WINDOW] 両親指レイヤー (英数 + かな + HJKL)
// ※ 最優先で評価させるため、index.ts で editRules より前に配置する
// =====================================================================
export const dualThumbRules = [
  rule("【WINDOW】両親指レイヤー (英数+かな+HJKL: スペース・ウィンドウ操作)").manipulators([
    map("h", "optionalAny")
      .to("left_arrow", "control")
      .condition(ifVar("eisuu_pressed", 1), ifVar("kana_pressed", 1)), // 左のスペース
    map("l", "optionalAny")
      .to("right_arrow", "control")
      .condition(ifVar("eisuu_pressed", 1), ifVar("kana_pressed", 1)), // 右のスペース
    map("j", "optionalAny")
      .to("h", "command")
      .condition(ifVar("eisuu_pressed", 1), ifVar("kana_pressed", 1)), // 隠す (Cmd+H)
    map("k", "optionalAny")
      .to("return_or_enter", ["left_control", "left_option"])
      .condition(ifVar("eisuu_pressed", 1), ifVar("kana_pressed", 1)), // 最大化（Rectangle / Raycast）
  ]),
];

export const windowRules = [
  // =====================================================================
  // [WINDOW] タブ・ウィンドウ操作 (グローバル)
  // ※ Ctrl+Q (Cmd+W) は Zellij と干渉するため廃止
  // =====================================================================


  // =====================================================================
  // [WINDOW] かなレイヤー (ウィンドウマネジメント・スペース移動)
  // =====================================================================
  rule("【WINDOW】かなレイヤー (Rectangle & Mac標準ウィンドウ操作)").manipulators(
    [
      // ----------------
      // 1. ウィンドウ配置・スペース・ディスプレイ（かなレイヤー）
      // ----------------
      // かな + H: アプリ非表示 (Cmd+H / Hide) - 右手完結の最速退避
      map("h", "optionalAny")
        .to("h", "command")
        .condition(ifVar("kana_pressed", 1)),

      // 【フォールバック】かな + 矢印キー
      map("left_arrow", "optionalAny")
        .to("left_arrow", "control")
        .condition(ifVar("kana_pressed", 1)), // 左のスペース
      map("right_arrow", "optionalAny")
        .to("right_arrow", "control")
        .condition(ifVar("kana_pressed", 1)), // 右のスペース
      map("down_arrow", "optionalAny")
        .to("h", "command")
        .condition(ifVar("kana_pressed", 1)), // 隠す (Cmd+H)
      map("up_arrow", "optionalAny")
        .to("return_or_enter", ["left_control", "left_option"])
        .condition(ifVar("kana_pressed", 1)), // 最大化（Rectangle / Raycast）
      // Shift 付きを optionalAny より前。残った Shift で最大化が吸われないように左右を分けて必須化する。
      map("k", "left_shift", "any")
        .to("f", ["control", "command"])
        .condition(ifVar("kana_pressed", 1)), // フルスクリーン
      map("k", "right_shift", "any")
        .to("f", ["control", "command"])
        .condition(ifVar("kana_pressed", 1)), // フルスクリーン
      map("k", "optionalAny")
        .to("return_or_enter", ["left_control", "left_option"])
        .condition(ifVar("kana_pressed", 1)), // 最大化（Rectangle / Raycast）
      // Reasonable Size: Raycast Window Management (Preset: Ctrl+Opt+Cmd+R)
      map("r", "optionalAny")
        .to("r", ["left_control", "left_option", "left_command"])
        .condition(ifVar("kana_pressed", 1)),
      map("comma", "optionalAny")
        .to("left_arrow", ["left_control", "left_option"])
        .condition(ifVar("kana_pressed", 1)), // 左半分（Rectangle）
      map("period", "optionalAny")
        .to("right_arrow", ["left_control", "left_option"])
        .condition(ifVar("kana_pressed", 1)), // 右半分（Rectangle）
      map("slash", "left_shift", "any")
        .to("f", ["control", "command"])
        .condition(ifVar("kana_pressed", 1)), // フルスクリーン
      map("slash", "right_shift", "any")
        .to("f", ["control", "command"])
        .condition(ifVar("kana_pressed", 1)), // フルスクリーン
      map("slash", "optionalAny")
        .to("return_or_enter", ["left_control", "left_option"])
        .condition(ifVar("kana_pressed", 1)), // 最大化（Rectangle / Raycast）
      // Next Display: Rectangle の Ctrl+Opt+Cmd+Right。HHKB は ; 、Conductor は Del と MB1。
      map("semicolon", "optionalAny")
        .to("right_arrow", ["left_control", "left_option", "left_command"])
        .condition(ifVar("kana_pressed", 1)),
      // Next Display の名残。HHKB / JIS のろ。主は semicolon
      map("international1", "optionalAny")
        .to("right_arrow", ["left_control", "left_option", "left_command"])
        .condition(ifVar("kana_pressed", 1)),
      map("delete_forward", "optionalAny")
        .to("right_arrow", ["left_control", "left_option", "left_command"])
        .condition(ifVar("kana_pressed", 1)),
      mapPointingButton("button1")
        .to("right_arrow", ["left_control", "left_option", "left_command"])
        .condition(
          ifVar("kana_pressed", 1),
          ifDevice({ vendor_id: 0x1d50, product_id: 0x615e }),
        ),
      // Switch Display Preset (Cmd+Opt+Ctrl+Shift+D)
      map("d", "optionalAny")
        .to("d", ["left_command", "left_option", "left_control", "left_shift"])
        .condition(ifVar("kana_pressed", 1)),
      // Mission Control (Ctrl+Up)
      map("quote", "optionalAny")
        .to("up_arrow", "control")
        .condition(ifVar("kana_pressed", 1)),
    ],
  ),

  // =====================================================================
  // 【WINDOW】Raycast Windows Management (template)
  // =====================================================================
  rule("【WINDOW】Rectangle Windows Management (template)").manipulators([
    // Option+, でウィンドウを左半分に配置（Rectangle: Ctrl+Opt+←）
    // (他での役割が出るまで)英数+,でも発火するようにする
    map("comma", "option").to("left_arrow", ["left_control", "left_option"]),
    map("comma", "optionalAny")
      .to("left_arrow", ["left_control", "left_option"])
      .condition(ifVar("eisuu_pressed", 1)),
    // Option+. でウィンドウを右半分に配置（Rectangle: Ctrl+Opt+→）
    // (他での役割が出るまで)英数+.でも発火するようにする
    map("period", "option").to("right_arrow", ["left_control", "left_option"]),
    map("period", "optionalAny")
      .to("right_arrow", ["left_control", "left_option"])
      .condition(ifVar("eisuu_pressed", 1)),
    // Option+kでウィンドウを最大化（Rectangle: Ctrl+Opt+Return）
    map("k", "option").to("return_or_enter", ["left_control", "left_option"]),
    // Option+rでウィンドウをReasonable Sizeに配置（Raycast: Ctrl+Opt+Cmd+R）
    map("r", "option").to("r", ["left_control", "left_option", "left_command"]),
    // Option+jでターミナル/パネルをトグル（Cmd+J）
    // ※ 英数レイヤー（英数+Opt+J: 段落移動）と競合しないよう、eisuu_pressed != 1 の時のみ発火
    map("j", "option")
      .to("j", "command")
      .condition(ifVar("eisuu_pressed", 1).unless()),
    // Option+nでNext Displayへ移動(Cmd+Opt+Control+n)
    // map("n", "option").to("n", ["left_command", "left_option", "left_control"]),
  ]),
];
