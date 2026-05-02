import { ifVar, map, rule } from "karabiner.ts";

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
    // アプリ起動
    // -------------------------------------------------------------
    map("m", "optionalAny")
      .toApp("Visual Studio Code")
      .condition(ifVar("kana_pressed", 1)),
    map("s", "optionalAny").toApp("Slack").condition(ifVar("kana_pressed", 1)),
    // map("t", "optionalAny")
    //     .toApp("Terminal")
    //     .condition(ifVar("kana_pressed", 1)),
    map("w", "optionalAny").toApp("Warp").condition(ifVar("kana_pressed", 1)),
    map("e", "optionalAny").toApp("Mail").condition(ifVar("kana_pressed", 1)),
    // map("b", "optionalAny")
    //   .toApp("Bitwarden")
    //   .condition(ifVar("kana_pressed", 1)),
    map("b", "optionalAny") // safari(ブラウザのB)
      .toApp("Safari")
      .condition(ifVar("kana_pressed", 1)),
    map("f", "optionalAny")
      .to$(`open -a Finder`)
      .condition(ifVar("kana_pressed", 1)),
    map("p", "optionalAny") // powerpoint
      .toApp("Microsoft PowerPoint")
      .condition(ifVar("kana_pressed", 1)),
    // map("z", "optionalAny") // zoom
    //   .toApp("zoom.us")
    //   .condition(ifVar("kana_pressed", 1)),
    map("z", "optionalAny") // zed
      .toApp("Zed")
      .condition(ifVar("kana_pressed", 1)),

    // Vivaldi PWA
    //  Notion(PWA in Vivaldi)の絶対パス起動
    map("n", "optionalAny")
      .to$(
        `open '/Users/mikoto/Applications/Vivaldi Apps.localized/Notion.app'`,
      )
      .condition(ifVar("kana_pressed", 1)),
    // GoogleCalendar(PWA in Vivaldi)の絶対パス起動
    map("c", "optionalAny")
      .to$(
        `open '/Users/mikoto/Applications/Vivaldi Apps.localized/GoogleCalendar.app'`,
      )
      .condition(ifVar("kana_pressed", 1)),
    // Gemini(PWA in Vivaldi)の絶対パス起動
    map("g", "optionalAny")
      .to$(
        `open '/Users/mikoto/Applications/Vivaldi Apps.localized/Gemini.app'`,
      )
      .condition(ifVar("kana_pressed", 1)),

    // Vivaldiは特殊構造のためBundle IDで強制起動
    map("v", "optionalAny")
      .to$(`open -b com.vivaldi.Vivaldi`)
      .condition(ifVar("kana_pressed", 1)),
  ]),
];
