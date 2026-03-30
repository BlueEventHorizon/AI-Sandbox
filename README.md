# AI Sandbox

AI コーディングアシスタント（Claude Code、OpenAI Codex）を Docker コンテナ内で安全に実行するための環境です。

ターゲットとなる git プロジェクトを指定してコンテナを起動すると、プロジェクトがコンテナ内にマウントされ、`claude` / `codex` コマンドが即座に使えます。

## 必要なもの

- macOS または Linux
- Docker（macOS の場合は Colima）
- Git

## セットアップ

### macOS の場合

```bash
# このリポジトリをクローン
git clone <repository-url> && cd AI-Sandbox

# Docker 環境をセットアップ（Docker + Colima + Buildx をインストール）
make install
```

### Linux の場合

Docker がインストール済みであれば追加セットアップは不要です。

## 使い方

### ターミナルから起動（推奨）

```bash
# ターゲットプロジェクトを指定してコンテナを起動
./setup-sandbox.sh ~/projects/my-app

# コンテナ内のシェルに入る
# /workspace $ claude    ← Claude Code が使える
# /workspace $ codex     ← OpenAI Codex が使える
# /workspace $ exit      ← コンテナから抜ける
```

初回実行時は Docker イメージが自動的にビルドされます（数分かかります）。

### VS Code で使う

```bash
# ターゲットプロジェクトに .devcontainer/ を配置
./setup-sandbox.sh --vscode ~/projects/my-app

# VS Code でプロジェクトを開く
code ~/projects/my-app
# → 「Reopen in Container」の提案が表示される
```

### オプション

| オプション | 説明 |
| --- | --- |
| `--rebuild` | イメージを強制再ビルドして起動（ツール更新時に使用） |
| `--vscode` | ターゲットに `.devcontainer/` を配置（コンテナは起動しない） |
| `-h`, `--help` | ヘルプを表示 |

## 複数プロジェクトの同時利用

異なるターミナルから異なるプロジェクトを同時に起動できます。各コンテナは独立して動作します。

```bash
# ターミナル 1
./setup-sandbox.sh ~/projects/app-A

# ターミナル 2
./setup-sandbox.sh ~/projects/app-B
```

## 認証情報の永続化

Claude Code の認証情報（`~/.claude/`）は Docker Named Volume に保存されます。コンテナを終了・再起動しても認証は保持されるため、毎回ログインする必要はありません。

## トラブルシューティング

### イメージのビルドに失敗する（macOS）

Colima のメモリ不足が原因の可能性があります。

```bash
colima stop
colima start --memory 4
./setup-sandbox.sh --rebuild ~/projects/my-app
```

### Docker が起動していない

```bash
# macOS の場合
colima start --memory 4

# 状態確認
colima status
```

### ツールを最新版に更新したい

```bash
./setup-sandbox.sh --rebuild ~/projects/my-app
```

イメージが再ビルドされ、Claude Code と Codex の最新版がインストールされます。
