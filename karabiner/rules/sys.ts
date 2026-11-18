import { ifVar, map, rule } from "karabiner.ts";

export const sysRules = [
  // =====================================================================
  // [SYS] コア・モディファイア設定
  // =====================================================================
  rule("【SYS】英数/かなキーをモディファイア化").manipulators([
    // CapsLockを左Optionとして利用
    map("caps_lock", "optionalAny").to("left_option"),

    // optionalAnyをつけることで、Shift等を押しながらでもフラグが立つようにする
    map("japanese_eisuu", "optionalAny")
      .to({ set_variable: { name: "eisuu_pressed", value: 1 } })
      .toAfterKeyUp({
        set_variable: { name: "eisuu_pressed", value: 0 },
      })
      .toIfAlone("japanese_eisuu"),

    map("japanese_kana", "optionalAny")
      .to({ set_variable: { name: "kana_pressed", value: 1 } })
      .toAfterKeyUp({
        set_variable: { name: "kana_pressed", value: 0 },
      })
      .toIfAlone("japanese_kana"),
  ]),

  // =====================================================================
  // [SYS] JIS配列補正
  // =====================================================================
  rule("【SYS】ろキー(international1)をバックスラッシュに変換").manipulators([
    // 素押しはクリップボード経由で literal な backslash を貼り付ける
    // Shift+ろ(アンダーバー)はこのルールにマッチしないため、既定動作を維持する
    map("international1")
      .to("international3", "left_option")
      .condition(ifVar("kana_pressed", 1).unless()),
  ]),
];
