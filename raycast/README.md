# Raycast（新端末）

窓の動きは Raycast Window Management。Preset の Rectangle は、そのホットキーだけを Rectangle の推奨既定に揃える。サイズの計算や、次のディスプレイで割合を保つかは Raycast のまま。

## インストール後に一度やる

1. Raycast を入れる。
2. Settings → Extensions → Window Management → Presets → **Rectangle**。
   - v1.19 以降。Left Half は Ctrl+Opt+←、Maximize は Ctrl+Opt+Return、Next Display は Ctrl+Opt+Cmd+→。Karabiner が送っているコードと揃う。
3. Left / Right Half の繰り返しを、1/2 → 2/3 → 1/3 にする（同じホットキーの連打）。
4. Rectangle アプリが残っているあいだは、同じホットキーが二重に鳴る。Preset のあとで Rectangle は終了する。

`raycast/raycast.rayconfig` は 2026-08-30 の暗号化バックアップで、この Preset は入っていない。Preset を押したあとに Export Settings & Data で取り直す。

## Import は GUI

`Import Settings & Data` をスクリプトから最後まで実行することはできない。deeplink `raycast://extensions/raycast/raycast/import-settings-data` は確認ダイアログを出すだけで、カテゴリのチェックとパスフレーズは画面で行う。サイレント import の API はない。クラウド同期と定期エクスポートは Pro。

## 端ドラッグ

2026-09-30 にシステム設定から戻した。MBA の `defaults read com.apple.WindowManager` は `EnableTilingByEdgeDrag = 1`。Option を押しながらタイルするキーと、上端へのドラッグは 0 のまま。余白も 0。
