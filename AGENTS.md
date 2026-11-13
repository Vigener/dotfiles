# dotfiles AGENTS.md

このリポジトリ（\`dotfiles\`）で作業する AI エージェント向けの規約・制約。
全体共通ルールは \`agents/GLOBAL_RULES.md\` を参照。

## 1. パッケージ管理（Homebrew / Brewfile）の鉄則

- **単一 Brewfile の原則**:
  - \`dotfiles/Brewfile\` は全端末（研究室常設の共有 Mac mini を含む）で共通利用される。
- **セキュリティ・クリティカルなアプリの除外（重要・絶対遵守）**:
  - \`ente-auth\`（2FA/TOTP 認証器）等の **機密シークレットを扱うアプリは \`Brewfile\` に絶対に記載しない**。
  - 研究室常設の Mac mini への流入を防ぐため、信頼できる手元端末（MacBook Air）でのみ単体手動インストール（\`brew install --cask ente-auth\`）を行う。
  - （※argon-sub 裁定: 自動化分岐スクリプトは設定ミスやホスト名変更で誤爆するリスクがあるため、コード管理から外すことで Mac mini への誤インストール確率を構造的に 0% に保つ）
- **\`brew bundle cleanup\` の禁止・制限**:
  - \`Brewfile\` に記載のない手動インストールアプリ（\`ente-auth\` 等）が強制削除される事故を防ぐため、**\`brew bundle cleanup --force\` の実行は禁止**。
  - cleanup を行う場合は必ず \`--force\` を外した dry-run で対象を確認すること。
