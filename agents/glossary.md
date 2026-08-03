# 用語・省略名（エージェント共通）

どのディレクトリ・どのマシンのセッションでも、以下を **同一の意味** で解釈すること。  
正本: このファイル（`~/dotfiles/agents/glossary.md`）。会話・wiki での略もこれに合わせる。

## マシン

| 略 | 正式 | SSH 例 | 備考 |
|---|---|---|---|
| **MBA** | MacBook Air (M4) | `ssh mac` | 画面・司令塔。持ち歩き |
| **TB** | ThinkPad (E14 等・Ubuntu) | `ssh thinkpad` | 保険・Linux・ジャンプ。旧母艦 |
| **mini** | Mac mini (M2 Pro) | `ssh mini` / `ssh mini-lan` | **現行母艦**（2026-08〜）。`MM` は使わない |

## リポジトリ・作業木

| 略 | 正式 | 実体パスの目安（正本は ghq） |
|---|---|---|
| **rb** | research-brain | `~/ghq/github.com/Vigener/research-brain` |
| **sandbox** | hybrid-workflow-sandbox | `~/ghq/github.com/Vigener/hybrid-workflow-sandbox` |

- `HWS` は使わない（曖昧）。必要ならフルネームか **sandbox**。
- 機種ごとの `~/brain/...` / `~/projects/...` は歴史的パス。言及するときは ghq か略称でよい。

## ツール・その他

| 略 | 正式 |
|---|---|
| **KE** | Karabiner-Elements |
| **OMZ** | Oh My Zsh（廃止方向・使わない） |

## HTTP 常駐（例）

| 名前 | 典型ポート | 配信元 |
|---|---|---|
| `http-brain` | 8766 | rb |
| `http-sandbox` | 8765 | sandbox |

配信ホストは **現行母艦 = mini**（旧 TB 並走あり）。URL は `localhost` または Tailscale IP。

## 更新

略称を増やす・変えるときはこのファイルを先に直し、必要なら `GLOBAL_RULES.md` の一行案内は維持する。
