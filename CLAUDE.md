# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# AI Sandbox

AI コーディングアシスタント（Claude Code、OpenAI Codex）をネイティブバイナリとしてプリインストールした Ubuntu 24.04 ベースの Docker コンテナ環境。

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

## CI/CD

- `.github/workflows/claude.yml`: Issue/PR で `@claude` メンションすると Claude Code が自動応答する GitHub Actions ワークフロー

## 検証コマンド

```bash
# Docker イメージのビルド
docker build -t ai-sandbox .devcontainer/

# コンテナ内でツールの動作確認
claude --version
codex --version
gh --version
python3 --version

# macOS: Colima の状態確認
colima status
```

## コンテナ内の Claude Code 権限設計

コンテナはホスト Mac のルートから隔離されているため、AI への権限を大幅に委譲している。

- **`claude` コマンド**: `--dangerously-skip-permissions` が自動付与され、確認プロンプトなしで実行される
- **禁止操作（コンテナ外に影響するもののみ）**:
  - `git push --force` 系（リモートリポジトリの破壊）
  - `.env*`・SSH 秘密鍵の読み書き
- **ターゲットプロジェクトの `.claude/settings.json`**: `--dangerously-skip-permissions` によりバイパスされるため、そのままコンテナに持ち込んでも制約にならない

## 開発メモ

- Docker ビルド時に Colima のメモリが 8GiB 以上必要（`colima start --memory 8`）
- `curl | bash`（Claude Code インストーラー）は Anthropic 公式がサポートする唯一のネイティブインストール方法
- Codex は GitHub Releases から glibc バイナリを直接取得
- 仕様書は `specs/` 配下（requirements/ design/ plan/）に格納。変更時は関連する仕様書との整合性を確認すること
