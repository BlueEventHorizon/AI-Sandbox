# AI Sandbox

AI コーディングアシスタント（Claude Code、OpenAI Codex）を Docker コンテナ内で安全に実行するための環境です。

ターゲットとなる git プロジェクトを指定してコンテナを起動すると、プロジェクトがコンテナ内にマウントされ、`claude` / `codex` コマンドが即座に使えます。`git`、`gh`（GitHub CLI）、`python3` も標準でインストール済みです。

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

## AI への権限委譲

### なぜ AI Sandbox では権限を広げられるか

通常のプロジェクトで Claude Code を使う場合、`rm -rf` や `curl` などの操作は誤実行を防ぐために確認プロンプトが表示されます。しかし AI Sandbox ではコンテナがホスト Mac のファイルシステムを隔離しているため、**最悪の場合でもターゲットプロジェクトの1ディレクトリしか影響を受けません**（Mac のルートは守られます）。

この安全性を活かして、AI Sandbox では `claude` コマンドに自動的に `--dangerously-skip-permissions` が付与されます。これにより：

- **確認プロンプトなし**でコードの生成・編集・実行・削除が連続して進む
- **ターゲットプロジェクトに独自の `.claude/settings.json` があっても制約を受けない**
- AI が自律的に作業を進められるため、複雑なタスクをより短時間で完結できる

コンテナに入ると以下の警告が赤字で表示されます：

```
⚠️  AI Sandbox: claude は --dangerously-skip-permissions モードで動作します。AI への権限が大幅に委譲されています。
```

### 禁止されている操作

コンテナ外に影響する操作のみ禁止しています：

| 禁止操作 | 理由 |
| --- | --- |
| `git push --force` 系 | リモートリポジトリを破壊するため |
| `.env*` / SSH 秘密鍵の読み書き | 機密情報の漏洩リスク |

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
