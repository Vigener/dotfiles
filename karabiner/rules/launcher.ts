import { ifVar, ifApp, map, rule, FromKeyParam, toSetVar } from "karabiner.ts";

// =====================================================================
// 🛠️ ヘルパー関数1: 通常アプリのトグル (Karabinerネイティブ監視)
// =====================================================================
function toggleApp(key: FromKeyParam, appName: string, bundleId: string) {
  return [
    map(key, "optionalAny")
      .to("h", "command")
      .condition(ifVar("kana_pressed", 1), ifApp(bundleId)),
    map(key, "optionalAny").toApp(appName).condition(ifVar("kana_pressed", 1)),
  ];
}

// =====================================================================
// 🛠️ ヘルパー関数2: PWA用トグル (AppleScriptを利用した究極の抜け道)
// =====================================================================
function togglePwa(key: FromKeyParam, processName: string, appPath: string) {
  const script = `osascript -e 'tell application "System Events"' -e 'if frontmost of process "${processName}" then' -e 'set visible of process "${processName}" to false' -e 'else' -e 'tell application "${appPath}" to activate' -e 'end if' -e 'end tell'`;

  return [
    map(key, "optionalAny").to$(script).condition(ifVar("kana_pressed", 1)),
  ];
}

export const launcherRules = [
  // =====================================================================
  // [APP] かなコンビネーション (メディア操作・アプリ起動)
  // =====================================================================
  rule("【APP】かなレイヤー (アプリ起動・メディア操作)").manipulators([
    // -------------------------------------------------------------
    // メディア操作
    // -------------------------------------------------------------
    map("spacebar", "optionalAny")
      .to("play_or_pause")
      .condition(ifVar("kana_pressed", 1)),
    map("u", "optionalAny").to("volume_up").condition(ifVar("kana_pressed", 1)),
    map("i", "optionalAny")
      .to("volume_down")
      .condition(ifVar("kana_pressed", 1)),
    map("y", "optionalAny").to("mute").condition(ifVar("kana_pressed", 1)),

    // -------------------------------------------------------------
    // アプリ起動 (ネイティブアプリ: トグル式)
    // -------------------------------------------------------------
    ...toggleApp("m", "Visual Studio Code", "^com\\.microsoft\\.VSCode$"),
    ...toggleApp("s", "Slack", "^com\\.tinyspeck\\.slackmacgap$"),
    ...toggleApp("t", "Terminal", "^com\\.apple\\.Terminal$"),
    ...toggleApp("w", "Warp", "^dev\\.warp\\.Warp-Stable$"),
    ...toggleApp("e", "Mail", "^com\\.apple\\.mail$"),
    ...toggleApp("b", "Google Chrome", "^com\\.google\\.Chrome$"),
    ...toggleApp("n", "Notion", "^notion\\.id$"),
    ...toggleApp("z", "Zed", "^dev\\.zed\\.Zed$"),
    ...toggleApp("v", "Vivaldi", "^com\\.vivaldi\\.Vivaldi$"),
    ...toggleApp("f", "Finder", "^com\\.apple\\.finder$"),

    // -------------------------------------------------------------
    // 📅 Notion Calendar (ダブルタップ機構)
    // -------------------------------------------------------------
    // 【2回目タップ】 500ms以内に再度 c が押されたら Cmd+1 を送信しウィンドウ展開
    map("c", "optionalAny")
      .to("1", "left_command")
      .toVar("notion_cal_tapped", 0) // フラグを即座にリセット
      .condition(ifVar("kana_pressed", 1), ifVar("notion_cal_tapped", 1)),

    // 【1回目タップ】 常駐バーを開く(Cmd+Ctrl+K) + フラグを1にし、500ms後に0に戻す
    map("c", "optionalAny")
      .to("k", ["left_command", "left_control"])
      .toVar("notion_cal_tapped", 1)
      .toDelayedAction(
        [{ set_variable: { name: "notion_cal_tapped", value: 0 } }],
        [{ set_variable: { name: "notion_cal_tapped", value: 0 } }],
      )
      .condition(
        ifVar("kana_pressed", 1),
        ifVar("notion_cal_tapped", 0), // まだタップされていない場合のみ発火
      ),

    // -------------------------------------------------------------
    // アプリ起動 (PWA: AppleScriptトグル式)
    // -------------------------------------------------------------
    ...togglePwa(
      "g",
      "Gemini",
      "/Users/mikoto/Applications/Vivaldi Apps.localized/Gemini.app",
    ),

    // -------------------------------------------------------------
    // アプリ起動 (ドキュメント系: サイクル式)
    // -------------------------------------------------------------
    map("p", "optionalAny")
      .to("open_bracket", "left_command")
      .condition(
        ifVar("kana_pressed", 1),
        ifApp("^com\\.microsoft\\.Powerpoint$"),
      ),
    map("p", "optionalAny")
      .toApp("Microsoft PowerPoint")
      .condition(
        ifVar("kana_pressed", 1),
        ifApp("^com\\.microsoft\\.Powerpoint$").unless(),
      ),

    map("r", "optionalAny")
      .to("open_bracket", "left_command")
      .condition(ifVar("kana_pressed", 1), ifApp("^com\\.apple\\.Preview$")),
    map("r", "optionalAny")
      .toApp("Preview")
      .condition(
        ifVar("kana_pressed", 1),
        ifApp("^com\\.apple\\.Preview$").unless(),
      ),
  ]),
];
