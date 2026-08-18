import { ifApp, ifVar, map, rule } from "karabiner.ts";
import type { FromKeyParam, ModifierParam } from "karabiner.ts";

// 試用。要らなくなったらこのファイルと index.ts の cmuxRules を消す。
const CMUX = "^com\\.cmuxterm\\.app$";

function herdrPrefix(
  from: FromKeyParam,
  letter: "c" | "x" | "f" | "q",
  mandatory?: ModifierParam,
  optional?: ModifierParam,
) {
  const m =
    mandatory !== undefined && optional !== undefined
      ? map(from, mandatory, optional)
      : mandatory !== undefined
        ? map(from, mandatory)
        : map(from);
  return m
    .to({
      select_input_source: { input_source_id: "com.apple.keylayout.ABC" },
    })
    .toNone({ hold_down_milliseconds: 100 })
    .to("spacebar", "left_control")
    .to(letter);
}

function eisuuCtrlAlt(
  key: "h" | "j" | "k" | "l" | "v" | "d" | "hyphen",
) {
  return map(key, "left_control", "any")
    .to(key, ["left_control", "left_option"])
    .condition(ifVar("eisuu_pressed", 1), ifApp(CMUX));
}

export const cmuxRules = [
  // Ghostty は cmd+t=text:\x00c 等（PTY 直書き）。Cmux はキーイベントなので
  // かなだと文字が変換に吸われる。ABC → 100ms → ctrl+space, letter。
  // Ctrl+Tab は herdr が直バインドしているので、Cmux が食わなければ触らない。
  rule("【Cmux】herdr prefix キー (T/W/P/Q)").manipulators([
    herdrPrefix("t", "c", "optionalAny").condition(
      ifVar("eisuu_pressed", 1),
      ifApp(CMUX),
    ),
    herdrPrefix("t", "c", "command").condition(ifApp(CMUX)),
    herdrPrefix("w", "x", "optionalAny").condition(
      ifVar("eisuu_pressed", 1),
      ifApp(CMUX),
    ),
    herdrPrefix("w", "x", "command").condition(ifApp(CMUX)),
    herdrPrefix("p", "f", "optionalAny").condition(
      ifVar("eisuu_pressed", 1),
      ifApp(CMUX),
    ),
    herdrPrefix("p", "f", "command").condition(ifApp(CMUX)),
    herdrPrefix("q", "q", "left_control", "any").condition(ifApp(CMUX)),
  ]),

  rule("【Cmux】英数+Ctrl+HJKL/V/-/D を herdr 向けに変換").manipulators([
    eisuuCtrlAlt("d"),
    eisuuCtrlAlt("h"),
    eisuuCtrlAlt("j"),
    eisuuCtrlAlt("k"),
    eisuuCtrlAlt("l"),
    eisuuCtrlAlt("v"),
    eisuuCtrlAlt("hyphen"),
  ]),
];
