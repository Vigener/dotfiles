import { ifInputSource, map, rule } from "karabiner.ts";

export const azikRules = [
  // =====================================================================
  // [AZIK] 日本語入力時カスタム (長音・促音・頻出単語)
  // =====================================================================
  rule("【AZIK】セミコロンで促音(っ)、コロンで長音(ー)").manipulators([
    // USキーボードのコロンの位置を想定
    map("quote")
      .to("hyphen")
      .condition(ifInputSource({ language: "ja" })),
    // セミコロンを「x, t, u」の3ストロークに変換（macOS標準IME向け。Google日本語入力のAZIK併用時は競合注意）
    map("semicolon")
      .to("x")
      .to("t")
      .to("u")
      .condition(ifInputSource({ language: "ja" })),
  ]),
];
