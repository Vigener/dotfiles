import { ifApp, ifDevice, ifVar, map, mapPointingButton, rule } from "karabiner.ts";

// =====================================================================
// 🛡️ 条件定義: RaycastのSwitch Windowsモード中であること
// =====================================================================
// Raycastが前面にある時のみ発火させることで、変数が残り続けた際の暴発を完全に防ぐ
const ifRaycastMode = [
  ifVar("raycast_window_mode", 1),
  ifApp("^com\\.raycast\\.macos$"),
];

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
      // -------...---------
      // 1. ウィンドウ配置・スペース・ディスプレイ（かなレイヤー）
      // -------...---------
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
      // Conductor MB1（L 右隣）: かな中のみ Next Display。device_if で Mac トラックパッド・HHKB ポインティングを除外。
      // VID/PID は ZMK 既定 USB (0x1D50/0x615E)。実機の Conductor 表記が違えば差し替え。BLE は USB ID と一致しない可能性あり（未確認・未所持）。
      mapPointingButton("button1")
        .to("right_arrow", ["left_control", "left_option", "left_command"])
        .condition(
          ifVar("kana_pressed", 1),
          ifDevice({ vendor_id: 0x1d50, product_id: 0x615e }),
        ),
      // Mission Control (Ctrl+Up): かな+: (JISのコロン / quote)
      map("quote", "optionalAny")
        .to("up_arrow", "control")
        .condition(ifVar("kana_pressed", 1)),
      // Switch Display Preset (Raycast Display Placer: Cmd+Opt+Ctrl+Shift+d)
      map("d", "optionalAny")
        .to("d", ["left_control", "left_option", "left_command", "left_shift"])
        .condition(ifVar("kana_pressed", 1)),

      // -------...---------
      // 3. アプリ/ウィンドウ切替
      // -------...---------
      // かな+Right Cmd → Raycast Switch Windows（Cmd+Opt+Tab）
      // 英数+Tab → AltTab。Opt のホールドは sys.ts の to_if_other_key_pressed が担う
      // （ここは Tab / Shift+Tab のみ送り、英数離しまで UI を維持する）
      map("right_command", "optionalAny")
        .to("tab", ["left_command", "left_option"])
        .toVar("raycast_window_mode", 1)
        .condition(ifVar("kana_pressed", 1)),
      // Shift 付きを先に評価（optionalAny より前）
      map("tab", "left_shift", "any")
        .to("tab", "left_shift")
        .condition(ifVar("eisuu_pressed", 1)),
      map("tab", "right_shift", "any")
        .to("tab", "left_shift")
        .condition(ifVar("eisuu_pressed", 1)),
      map("tab", "optionalAny")
        .to("tab")
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
    // Option+nでNext Displayへ移動(Cmd+Opt+Control+n)
    // map("n", "option").to("n", ["left_command", "left_option", "left_control"]),
  ]),
];
