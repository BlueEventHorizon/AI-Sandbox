# AI Sandbox

AI コーディングアシスタント（Claude Code、OpenAI Codex）をネイティブバイナリとしてプリインストールした Ubuntu 24.04 ベースの Docker コンテナ環境。

## プロジェクト構成

```
.devcontainer/
  Dockerfile          # Ubuntu 24.04 + Claude Code + Codex
  devcontainer.json   # VS Code DevContainer 設定
setup-sandbox.sh      # エントリポイント（ターミナル起動 / VS Code 配置）
Makefile              # macOS Docker 環境セットアップ（Colima）
specs/                # 要件定義書・設計書・計画書
```

## アーキテクチャ

- **ベースイメージ**: Ubuntu 24.04（glibc 環境。Claude Code のネイティブバイナリが動作する）
- **npm / Node.js 不使用**: Anthropic 公式 DevContainer Feature（npm ベース）との差別化
- **エントリポイント**: `setup-sandbox.sh` が唯一の操作インターフェース
- **認証永続化**: Docker Named Volume（`ai-sandbox-claude-{プロジェクト名}`）で `~/.claude/` を永続化

## 共有定数（変更時は全ファイルを同時更新）

| 定数 | 値 | 使用箇所 |
| --- | --- | --- |
| ユーザー名 | `devuser` | Dockerfile, devcontainer.json |
| イメージ名 | `ai-sandbox` | setup-sandbox.sh |
| ワークスペース | `/workspace` | Dockerfile, setup-sandbox.sh, devcontainer.json |
| Claude 設定パス | `/home/devuser/.claude` | setup-sandbox.sh, devcontainer.json |
| Volume 名プレフィックス | `ai-sandbox-claude-` | setup-sandbox.sh, devcontainer.json |

## コマンド

```bash
# ターミナルから起動（優先ワークフロー）
./setup-sandbox.sh ~/projects/my-app

# イメージを再ビルドして起動
./setup-sandbox.sh --rebuild ~/projects/my-app

# VS Code 用に .devcontainer/ をターゲットにコピー
./setup-sandbox.sh --vscode ~/projects/my-app

# macOS Docker 環境セットアップ
make install
```

## 開発メモ

- Docker ビルド時に Colima のメモリが 4GiB 以上必要（`colima start --memory 4`）
- `curl | bash`（Claude Code インストーラー）は Anthropic 公式がサポートする唯一のネイティブインストール方法
- Codex は GitHub Releases から glibc バイナリを直接取得
