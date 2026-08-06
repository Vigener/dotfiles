import { ifVar, map, rule } from "karabiner.ts";

export const sysRules = [
  // =====================================================================
  // [SYS] コア・モディファイア設定
  // =====================================================================
  rule("【SYS】英数/かなキーをモディファイア化").manipulators([
    // CapsLockを左Optionとして利用
    map("caps_lock", "optionalAny").to("left_option"),

    // optionalAnyをつけることで、Shift等を押しながらでもフラグが立つようにする
    // Tab 併用時は英数自体を left_option に化けさせ、英数を離すまで Opt を維持する
    // （Tab 側で Opt+Tab を都度送ると Tab キーアップで Opt が切れ AltTab が閉じる）
    map("japanese_eisuu", "optionalAny")
      .to({ set_variable: { name: "eisuu_pressed", value: 1 } })
      .toIfOtherKeyPressed(
        [{ key_code: "tab", modifiers: { optional: ["any"] } }],
        [
          { set_variable: { name: "eisuu_pressed", value: 1 } },
          { key_code: "left_option" },
        ],
      )
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
  // [SYS] 右Cmd → 右Shift（腱鞘炎対策・親指付近の Shift 代替）
  //    - かな押下中は変換しない → かな+Right Cmd（Switch Windows）を維持
  //    - 物理左右 Shift は残す（必須化しない）
  // =====================================================================
  rule("【SYS】右Cmdを右Shiftに変換（かな押下中は除外）").manipulators([
    map("right_command", "optionalAny")
      .to("right_shift")
      .condition(ifVar("kana_pressed", 1).unless()),
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
