import { ifVar, ifApp, map, rule, FromKeyParam, toSetVar } from "karabiner.ts";

// =====================================================================
// 📖 アプリレジストリ: appName -> bundleId のペア一覧
//    - toggleApp() の第3引数を省略するために使用
//    - 一軍から外れたアプリもここに残しておくことで、再利用時にIDを再調査不要
// =====================================================================
const APP_REGISTRY: Record<string, string> = {
  // --- ブラウザ ---
  Dia: "^company\\.thebrowser\\.dia$",
  "Google Chrome": "^com\\.google\\.Chrome$",
  Zen: "^app\\.zen-browser\\.zen$",
  // --- 開発ツール ---
  Antigravity: "^com\\.google\\.antigravity$",
  cmux: "^com\\.cmuxterm\\.app$",
  Zed: "^dev\\.zed\\.Zed$",
  Cursor: "^com\\.todesktop\\.230313mzl4w4u92$",
  "Visual Studio Code": "^com\\.microsoft\\.VSCode$",
  Warp: "^dev\\.warp\\.Warp-Stable$",
  Ghostty: "^com\\.mitchellh\\.ghostty$",
  // --- コミュニケーション ---
  Slack: "^com\\.tinyspeck\\.slackmacgap$",
  Mail: "^com\\.apple\\.mail$",
  // --- システム ---
  Finder: "^com\\.apple\\.finder$",
  // --- ドキュメント ---
  "Microsoft PowerPoint": "^com\\.microsoft\\.Powerpoint$",
  Preview: "^com\\.apple\\.Preview$",
  Obsidian: "^md\\.obsidian$",
};

/** アプリ名からバンドルIDを取得する。見つからない場合はエラーをスロー */
function bundleId(appName: string): string {
  const id = APP_REGISTRY[appName];
  if (!id) throw new Error(`Bundle ID not found for app: "${appName}"`);
  return id;
}

// =====================================================================
// 🛠️ ヘルパー関数1: 通常アプリのトグル (Karabinerネイティブ監視)
// =====================================================================
function toggleApp(key: FromKeyParam, appName: string) {
  const id = bundleId(appName);
  return [
    map(key, "optionalAny")
      .to("h", "command")
      .condition(ifVar("kana_pressed", 1), ifApp(id)),
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

// =====================================================================
// 🛠️ ヘルパー関数3: キー送信付きアプリトグル (ラグ回避シークエンス内包)
//    - アクティブ時は Cmd+[tabKey] でピン留めタブへジャンプ
//    - 非アクティブ時はシェルコマンドでラグ回避しつつ起動＋キー送信
// =====================================================================
function toggleAppWithKey(
  key: FromKeyParam,
  appName: string,
  tabKey: string,
  modifiers: string[],
) {
  // AppleScriptを用いて、アプリを起動/前面化し、100ms待機してからショートカットを送信
  // M4 Macの処理速度であれば 100ms のディレイで確実にコンテキストスイッチが完了する
  const id = bundleId(appName);
  const modStr = modifiers.map((m) => `${m} down`).join(", ");
  const cleanBundleId = id.replace(/^\^|\$$/g, "").replace(/\\/g, "");
  const shellCommand = `open -b ${cleanBundleId} && osascript -e 'delay 0.1' -e 'tell application "System Events" to keystroke "${tabKey}" using {${modStr}}'`;

  return [
    // ① 対象アプリがすでにアクティブ（最前面）なら、Cmd+[tabKey] でタブへジャンプ
    map(key, "optionalAny")
      // @ts-expect-error - tabKey is a dynamic string but valid as a key code
      .to(tabKey, "command")
      .condition(ifVar("kana_pressed", 1), ifApp(id)),

    // ② アクティブでないなら、シェルコマンドでラグ回避しつつ起動＋キー送信
    map(key, "optionalAny")
      .to$(shellCommand)
      .condition(ifVar("kana_pressed", 1)),
  ];
}

// =====================================================================
// 🛠️ ヘルパー関数4: アプリがアクティブならキー送信、非アクティブならただ起動
// =====================================================================
function toggleAppOrSendKey(
  key: FromKeyParam,
  appName: string,
  keyToSend: string,
  modifiers: string[],
) {
  const id = bundleId(appName);
  return [
    map(key, "optionalAny")
      // @ts-expect-error - keyToSend is a dynamic string but valid as a key code
      .to(keyToSend, modifiers)
      .condition(ifVar("kana_pressed", 1), ifApp(id)),
    map(key, "optionalAny").toApp(appName).condition(ifVar("kana_pressed", 1)),
  ];
}

// =====================================================================
// 🛠️ ヘルパー関数5: Notion Calendar呼び出し (ダブルタップ機構)
// =====================================================================
function openNotionCalendar(key: FromKeyParam) {
  return [
    // 【2回目タップ】 500ms以内に再度キーが押されたら Cmd+1 を送信しウィンドウ展開
    map(key, "optionalAny")
      .to("1", "left_command")
      .toVar("notion_cal_tapped", 0) // フラグを即座にリセット
      .condition(ifVar("kana_pressed", 1), ifVar("notion_cal_tapped", 1)),

    // 【1回目タップ】 常駐バーを開く(Cmd+Ctrl+K) + フラグを1にし、500ms後に0に戻す
    map(key, "optionalAny")
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
  ];
}

// =====================================================================
// 🌐 現在のメインブラウザ設定
//    ブラウザ変更時はここだけを書き換える
// =====================================================================
const MAIN_BROWSER = "Dia";
// タブ配置: Cmd+2 で思考ハブ (N キー用)。Cmd+1 (旧 かな+G Gemini) は未割当。
const BROWSER_AGENT_TAB = "1"; // 旧 かな+G。レジストリ資産として残す
const BROWSER_HUB_TAB = "2"; // かな+N: 思考ハブタブ
const BROWSER_SLACK_TAB = "3"; // かな+S: Slackタブ
const BROWSER_CALENDAR_TAB = "4"; // かな+C: カレンダータブ
const BROWSER_MUSIC_TAB = "5"; // かな+8: YouTube Musicタブ

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
    ...toggleApp("o", "Obsidian"),
    ...toggleApp("a", "cmux"),
    ...toggleApp("m", "Cursor"),
    ...toggleApp("z", "Zed"),
    // 🚀 Sキー: メインブラウザを呼び出し、Cmd+[BROWSER_SLACK_TAB] でタブへジャンプ
    ...toggleAppWithKey("s", MAIN_BROWSER, BROWSER_SLACK_TAB, ["command"]),
    ...toggleApp("w", "Warp"),
    ...toggleApp("t", "Warp"),
    ...toggleApp("e", "Mail"),
    ...toggleApp("b", "Google Chrome"),

    // 🧠 Nキー: メインブラウザ (アクティブ時はCmd+[BROWSER_HUB_TAB]、非アクティブ時は起動)
    ...toggleAppOrSendKey("n", MAIN_BROWSER, BROWSER_HUB_TAB, ["command"]),

    ...toggleApp("v", "Visual Studio Code"),
    ...toggleApp("f", "Finder"),
    ...toggleApp("g", "Ghostty"),

    // 🚀 Cキー: メインブラウザを呼び出し、Cmd+[BROWSER_CALENDAR_TAB] でタブへジャンプ
    ...toggleAppWithKey("c", MAIN_BROWSER, BROWSER_CALENDAR_TAB, ["command"]),

    // 🎵 8キー: メインブラウザを呼び出し、Cmd+[BROWSER_MUSIC_TAB] でタブへジャンプ (YouTube Music)
    ...toggleAppWithKey("8", MAIN_BROWSER, BROWSER_MUSIC_TAB, ["command"]),

    // -------------------------------------------------------------
    // アプリ起動 (ドキュメント系: サイクル式)
    // -------------------------------------------------------------
    map("p", "optionalAny")
      .to("open_bracket", "left_command")
      .condition(
        ifVar("kana_pressed", 1),
        ifApp(bundleId("Microsoft PowerPoint")),
      ),
    map("p", "optionalAny")
      .toApp("Microsoft PowerPoint")
      .condition(
        ifVar("kana_pressed", 1),
        ifApp(bundleId("Microsoft PowerPoint")).unless(),
      ),

    map("r", "optionalAny")
      .to("open_bracket", "left_command")
      .condition(ifVar("kana_pressed", 1), ifApp(bundleId("Preview"))),
    map("r", "optionalAny")
      .toApp("Preview")
      .condition(ifVar("kana_pressed", 1), ifApp(bundleId("Preview")).unless()),
  ]),
];
