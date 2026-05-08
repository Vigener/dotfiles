import { ifVar, ifApp, map, rule } from "karabiner.ts";

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
    // アプリ起動 (最大27枠の厳選レイヤー: 役割/Roleベース)
    // -------------------------------------------------------------
    // [M] Code (VSCode) / Main editor
    map("m", "optionalAny")
      .toApp("Visual Studio Code")
      .condition(ifVar("kana_pressed", 1)),
    // [S] Slack
    map("s", "optionalAny").toApp("Slack").condition(ifVar("kana_pressed", 1)),
    // [T] Terminal (標準)
    map("t", "optionalAny")
      .toApp("Terminal")
      .condition(ifVar("kana_pressed", 1)),
    // [W] Warp (次世代ターミナル)
    map("w", "optionalAny").toApp("Warp").condition(ifVar("kana_pressed", 1)),
    // [E] Email (Mail)
    map("e", "optionalAny").toApp("Mail").condition(ifVar("kana_pressed", 1)),

    // [B] Browser (Safari) - Bitwardenから移行済み
    map("b", "optionalAny").toApp("Safari").condition(ifVar("kana_pressed", 1)),

    // [F] Finder
    map("f", "optionalAny")
      .to$(`open -a Finder`)
      .condition(ifVar("kana_pressed", 1)),

    // [Z] Zed (軽量エディタ)
    map("z", "optionalAny").toApp("Zed").condition(ifVar("kana_pressed", 1)),

    // -------------------------------------------------------------
    // 複数ウィンドウ切替 ＆ 起動系
    // -------------------------------------------------------------
    // 【P】 Presentation (PowerPoint)
    // ① パワポがすでに最前面の場合：次のウィンドウへ切り替え
    map("p", "optionalAny")
      .to("open_bracket", "left_command") // Cmd + [ : 次のウィンドウ
      .condition(
        ifVar("kana_pressed", 1),
        ifApp("^com\\.microsoft\\.Powerpoint$"),
      ),
    // ② パワポが最前面ではない場合：起動・アクティブ化
    map("p", "optionalAny")
      .toApp("Microsoft PowerPoint")
      .condition(
        ifVar("kana_pressed", 1),
        ifApp("^com\\.microsoft\\.Powerpoint$").unless(),
      ),

    // 【R】 Read / Reference (Preview) ※新規追加
    // ① プレビューがすでに最前面の場合：次のウィンドウへ切り替え
    map("r", "optionalAny")
      .to("open_bracket", "left_command")
      .condition(ifVar("kana_pressed", 1), ifApp("^com\\.apple\\.Preview$")),
    // ② プレビューが最前面ではない場合：起動・アクティブ化
    map("r", "optionalAny")
      .toApp("Preview")
      .condition(
        ifVar("kana_pressed", 1),
        ifApp("^com\\.apple\\.Preview$").unless(),
      ),

    // -------------------------------------------------------------
    // PWA (Vivaldi内) 絶対パス起動系
    // -------------------------------------------------------------
    // [N] Notion (PWA)
    map("n", "optionalAny")
      .to$(
        `open '/Users/mikoto/Applications/Vivaldi Apps.localized/Notion.app'`,
      )
      .condition(ifVar("kana_pressed", 1)),
    // [C] Calendar (GoogleCalendar PWA)
    map("c", "optionalAny")
      .to$(
        `open '/Users/mikoto/Applications/Vivaldi Apps.localized/GoogleCalendar.app'`,
      )
      .condition(ifVar("kana_pressed", 1)),
    // [G] Gemini (PWA)
    map("g", "optionalAny")
      .to$(
        `open '/Users/mikoto/Applications/Vivaldi Apps.localized/Gemini.app'`,
      )
      .condition(ifVar("kana_pressed", 1)),

    // [V] Vivaldi (メインブラウザ - Bundle ID起動)
    map("v", "optionalAny")
      .to$(`open -b com.vivaldi.Vivaldi`)
      .condition(ifVar("kana_pressed", 1)),
  ]),
];
