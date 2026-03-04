# AI DevContainer

DevContainer を使った AI 支援開発環境です。
コンテナ技術により、ローカル環境を汚さず、誰でも同じ開発環境を素早く構築できます。

## 主な特徴

- **AI コーディング支援**: Gemini CLI、Claude Code、OpenAI Codex が利用可能
- **軽量な環境**: Alpine Linux ベースの Node.js 24 環境
- **一貫性**: DevContainer により、OS の違い（macOS, Windows, Linux）を問わず統一された環境で開発可能
- **簡単セットアップ**: macOS なら `make install` で全自動、他の OS でも VS Code で開くだけ

## 利用方法

この DevContainer は以下の方法で利用できます：

### VS Code + DevContainers 拡張機能（推奨）

- [Visual Studio Code](https://code.visualstudio.com/)
- [DevContainers 拡張機能](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

エディタとコンテナが統合され、最も使いやすい環境です。

### 直接コンテナを利用

`docker` コマンドでコンテナを起動し、シェルから AI ツールを実行できます。
他のエディタ（Vim, Emacs, IntelliJ など）からもコンテナ内のツールにアクセス可能です。

## クイックスタート

### ==== macOSの場合 ====

Homebrew がインストールされていれば、以下のコマンドで全自動セットアップできます：

```bash
# リポジトリをクローン
git clone https://github.com/BlueEventHorizon/AI-DevContainer
cd AI-DevContainer

# 全自動セットアップ（Docker CLI, Colima, Buildx を自動インストール）
make install
```

これで Colima（Docker Desktop の無料代替）が起動します。

**2回目以降の起動：**
```bash
colima start
```

**停止：**
```bash
colima stop
```

**詳細**: macOS でのセットアップの詳細は [MAKEFILE_GUIDE.md](MAKEFILE_GUIDE.md) を参照してください。

環境構築が完了したら、続いて「使い方」セクションを参照してください。

### ==== Windows / Linuxの場合 ====

1. **Docker のインストール**
   - Windows: [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/)
   - Linux: [Docker Engine](https://docs.docker.com/engine/install/)

2. **リポジトリをクローン**
   ```bash
   git clone https://github.com/BlueEventHorizon/AI-DevContainer
   cd AI-DevContainer
   ```

これで環境構築は完了です。続いて「使い方」セクションを参照してください。

## 使い方

### VS Code での使い方（推奨）

0. **前提条件: DevContainers 拡張機能**

   DevContainers 拡張機能がインストールされている必要があります。

   **インストール方法:**
   - VS Code で拡張機能パネルを開く（`Ctrl+Shift+X` / `Cmd+Shift+X`）
   - 「Dev Containers」を検索
   - **Dev Containers**（Microsoft 提供）をインストール
   - または、[マーケットプレイス](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)から直接インストール

1. **VS Code で開く**

   VS Code でプロジェクトフォルダを開くと、**右下に通知が表示**されます：

   ```
   ファイルに開発コンテナーの構成ファイルが含まれています
   [コンテナーで再度開く]  [ボリュームでクローン]  [再表示しない...]
   ```

   **「コンテナーで再度開く」**（英語版: `Reopen in Container`）をクリックしてください。

   **通知が表示されない場合:**
   - コマンドパレット（`Ctrl+Shift+P` / `Cmd+Shift+P`）を開く
   - 「Dev Containers: Reopen in Container」を検索して実行

   コンテナのビルドが完了すると、VS Code がコンテナに接続された状態で再起動します。

2. **コンテナ接続の確認**

   VS Code の左下のステータスバーに「**Dev Container: ...**」と表示されていれば、コンテナに接続されています。

3. **統合ターミナルを開く**

   - メニュー: `Terminal` → `New Terminal`
   - ショートカット: `Ctrl+\`` (Windows/Linux) or `Cmd+\`` (macOS)

   ターミナルが開くと、コンテナ内のシェルが起動します。

4. **AI ツールを実行**

   ターミナルで以下のコマンドが使えます：

   ```bash
   # Gemini CLI
   gemini --help
   npm run gemini -- --help

   # Claude Code
   claude --help
   npm run claude -- --help

   # OpenAI Codex
   codex --help
   npm run codex -- --help
   ```

5. **開発フロー**

   - エディタでコードを編集
   - ターミナルで AI ツールに質問やコード生成を依頼
   - AI の回答を参考にコーディングを進める

### コンソールでの使い方（VS Code なし）

VS Code を使わず、直接コンテナを起動して使うこともできます。

**方法0: 起動スクリプトを使用（最も簡単）**

便利な起動スクリプトを用意しています：

```bash
# DevContainer を起動（イメージがなければ自動ビルド）
./start-container.sh

# シンプルな Node.js コンテナを起動
./start-container.sh --node

# DevContainer を再ビルドして起動
./start-container.sh --rebuild

# ヘルプを表示
./start-container.sh --help
```

**方法1: DevContainer イメージを使用**

```bash
# コンテナイメージをビルド
docker build -t ai-devcontainer -f .devcontainer/Dockerfile .

# コンテナを起動してシェルに入る（依存関係を自動インストール）
docker run -it --rm \
  -v "$(pwd)":/workspace \
  -w /workspace \
  ai-devcontainer sh -c "npm install --silent 2>/dev/null || true; exec sh -l"
```

コンテナに入ると、プロンプトが `/workspace #` のように変わります。

**コンテナ内にいることを確認:**

```bash
# Alpine Linux であることを確認
cat /etc/os-release

# Node.js 24 がインストールされていることを確認
node --version

# AI ツールが使えることを確認
gemini --help
claude --help
codex --help
```

**コンテナから抜ける:**

```bash
exit
```

**方法2: シンプルな Node.js コンテナを使用**

```bash
# Node.js コンテナを起動（依存関係を自動インストール）
docker run -it --rm \
  -v "$(pwd)":/workspace \
  -w /workspace \
  node:24-alpine sh -c "npm install --silent 2>/dev/null || true; exec sh -l"
```

コンテナに入ると、プロンプトが `/workspace #` のように変わります。

**コンテナ内での作業:**

依存関係は起動時に自動的にインストールされるので、すぐにAIツールが使えます：

```bash
# AI ツールを直接実行（エイリアスが有効）
gemini --help
claude --help
codex --help

# または npx 経由でも実行可能
npx gemini --help
npx claude --help
npx codex --help
```

**コンテナから抜ける:**

```bash
exit
```

### 利用可能な AI ツール

コンテナ環境内では、以下のツールが利用できます：

#### Gemini CLI

```bash
gemini --help        # 直接実行
npm run gemini -- --help  # npm script 経由
```

#### Claude Code

```bash
claude --help        # 直接実行
npm run claude -- --help  # npm script 経由
```

#### OpenAI Codex

```bash
codex --help         # 直接実行
npm run codex -- --help   # npm script 経由
```

## 既存プロジェクトへのインストール

この AI DevContainer 環境を既存のプロジェクトに追加できます。

### 自動インストール（推奨）

インストールスクリプトを使用して自動的にセットアップできます：

```bash
# 基本的な使い方
./install-devcontainer.sh /path/to/your/project

# 既存ファイルをバックアップしながらインストール
./install-devcontainer.sh --backup /path/to/your/project
```

スクリプトは以下の処理を自動で行います：

1. `.devcontainer/` ディレクトリのコピー
2. `package.json` の自動マージ（既存の場合は devDependencies と scripts を追加）
3. `.gitignore` の確認と更新（`node_modules/` の追加）
4. `start-container.sh` のコピー（コンソールからの起動用）
5. `Makefile` のコピー（オプション、macOS ユーザー向け）

### 手動インストール

手動でインストールする場合は、以下のファイルをコピーしてください：

1. **必須**: `.devcontainer/` ディレクトリ全体
2. **必須**: `package.json` に以下を追加（既存ファイルがある場合はマージ）
   ```json
   {
     "devDependencies": {
       "@anthropic-ai/claude-code": "latest",
       "@google/gemini-cli": "latest",
       "@openai/codex": "latest"
     },
     "scripts": {
       "gemini": "gemini",
       "claude": "claude",
       "codex": "codex"
     }
   }
   ```
3. **推奨**: `.gitignore` に `node_modules/` を追加
4. **推奨**: `start-container.sh`（コンソールからコンテナを起動する場合）
5. **オプション**: `Makefile`（macOS で Docker Desktop を使わない場合）

インストール後、VS Code でプロジェクトを開き、「Dev Containers: Reopen in Container」を実行してください。

## ファイル構成

- **`.devcontainer/`**: DevContainer の設定ファイル
  - `devcontainer.json`: ポート、拡張機能、ビルド方法などを定義
  - `Dockerfile`: コンテナのベースイメージとインストールするソフトウェアを定義
- **`package.json`**: プロジェクトの依存関係と npm スクリプトを定義
- **`start-container.sh`**: コンソールからコンテナを起動するスクリプト
- **`install-devcontainer.sh`**: 既存プロジェクトへの自動インストールスクリプト
- **`Makefile`**: (macOS ユーザー向け) Docker Desktop の代替として Colima をセットアップ
- **`.vscode/`**: VS Code エディタ固有の設定
  - `extensions.json`: このプロジェクトで推奨される VS Code 拡張機能を定義

## 参考情報

- [MAKEFILE_GUIDE.md](MAKEFILE_GUIDE.md): macOS での Colima セットアップの詳細
- [CLAUDE.md](CLAUDE.md): Claude Code 向けのプロジェクト情報
