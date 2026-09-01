# 🧩 Local Chrome Extensions

Chrome Web Store を介さず、ローカル（`ghq` 配下）から「パッケージ化されていない拡張機能」として読み込んでいる自作・独自拡張機能の管理カタログです。

> **Note**:  
> Web Store 経由の拡張機能とは異なり、ローカル読み込みの拡張機能は **Google アカウントによる拡張機能同期の対象外** です。  
> 新端末のセットアップ時や PC 移行時は、本ドキュメントのコマンドでリポジトリを取得し、Chrome に再読み込みしてください。

---

## 🚀 一括クローン・更新コマンド (ghq)

```bash
# SSH プロトコルで最新状態を取得 / 更新
ghq get -u -p Vigener/auto-tab-group
ghq get -u -p Vigener/pukiwiki-markdown-bridge
ghq get -u -p Vigener/manaba-quick-nav
```

---

## 📋 登録拡張機能一覧

| 拡張機能名 | リポジトリ | 概要 | 読み込み先パス |
| :--- | :--- | :--- | :--- |
| **auto-tab-group** | [Vigener/auto-tab-group](https://github.com/Vigener/auto-tab-group) | Cmd+クリックで親タブと同グループ化。1タブで自動解除（Dia / Zen風のタブスタック） | `~/ghq/github.com/Vigener/auto-tab-group` |
| **pukiwiki-markdown-bridge** | [Vigener/pukiwiki-markdown-bridge](https://github.com/Vigener/pukiwiki-markdown-bridge) | PukiWiki と Markdown の相互変換・編集ブリッジ拡張 | `~/ghq/github.com/Vigener/pukiwiki-markdown-bridge` |
| **manaba-quick-nav** | [Vigener/manaba-quick-nav](https://github.com/Vigener/manaba-quick-nav) | manaba コース検索・クイック遷移 SPA 拡張 | `~/ghq/github.com/Vigener/manaba-quick-nav` |

---

## 🛠 新端末での Chrome 登録手順

1. ターミナルで上記の一括クローンコマンドを実行します。
2. Chrome を開き、アドレスバーに `chrome://extensions/` と入力して開きます。
3. 画面右上の **「デベロッパー モード」** を ON にします。
4. 画面左上の **「パッケージ化されていない拡張機能を読み込む」** をクリックします。
5. 上記一覧のパス（例: `~/ghq/github.com/Vigener/auto-tab-group`）を選択して読み込みます。
