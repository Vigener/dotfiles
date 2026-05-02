import { writeToProfile } from "karabiner.ts";
import { appRules } from "./rules/app";
import { azikRules } from "./rules/azik";
import { editRules } from "./rules/edit";
import { launcherRules } from "./rules/launcher";
import { sysRules } from "./rules/sys";
import { windowRules } from "./rules/window";

writeToProfile(
  {
    name: "Default profile",
  },
  [
    // ---------------------------------------------------------------------
    // 各種ルールの読み込み
    // ※Karabinerは上に書かれたルールから順に評価されるため、
    // 優先させたいルール（例：アプリ固有設定）が先頭に来るように配置しています。
    // ---------------------------------------------------------------------
    ...appRules,
    ...sysRules,
    ...editRules,
    ...windowRules,
    ...launcherRules,
    ...azikRules,
  ],
);
