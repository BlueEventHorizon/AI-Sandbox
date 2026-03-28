# AI DevContainer

AI コーディングアシスタントがすぐに使える、DevContainer ベースの開発環境です。

コンテナ技術を使うことで、**ローカル環境を一切汚さず**に AI 支援開発を始められます。面倒なセットアップは不要 — コンテナを起動するだけで、すぐにコーディングを開始できます。

## この環境でできること

| AI ツール | 動作場所 | 説明 |
| --- | --- | --- |
| **OpenAI Codex** | コンテナ内 | コンテナにプリインストール済み。ターミナルから `codex` コマンドで利用 |
| **Claude Code** | ホスト（VS Code 拡張） | VS Code の拡張機能として動作。コンテナに接続した状態で利用 |

## 主な特徴

- **即時利用**: コンテナを起動するだけ。追加のインストール作業は不要
- **環境を汚さない**: すべてコンテナ内で完結。ローカル環境に影響なし
- **軽量**: Alpine Linux ベース。npm / Node.js は使いません
- **再現性**: 同じ Dockerfile から、誰でも同じ環境を構築できる
- **2つの利用方法**: VS Code（推奨）でもターミナルからでも使える

---

## 目次

- [環境構築（初回のみ）](#環境構築初回のみ)
  - [macOS の場合](#macos-の場合)
  - [Linux の場合](#linux-の場合)
- [使い方](#使い方)
  - [VS Code で使う（推奨）](#vs-code-で使う推奨)
  - [ターミナルから使う](#ターミナルから使う)
- [AI ツールの使い方](#ai-ツールの使い方)
- [既存プロジェクトへの導入](#既存プロジェクトへの導入)
- [コンテナの管理](#コンテナの管理)
- [ファイル構成](#ファイル構成)
- [トラブルシューティング](#トラブルシューティング)

---

## 環境構築（初回のみ）

### 必要なもの

| ソフトウェア | 用途 | 備考 |
| --- | --- | --- |
| **Docker** | コンテナの実行環境 | macOS なら `make install` で自動セットアップ |
| **Git** | リポジトリのクローン | |
| **VS Code** + DevContainers 拡張 | （推奨）エディタとコンテナの統合 | ターミナルのみの利用なら不要 |

### macOS の場合

macOS では Docker Desktop の代わりに **Colima**（無料の OSS）を使います。
Homebrew がインストールされていれば、以下のコマンドだけで全自動セットアップできます。

```bash
# 1. リポジトリをクローン
git clone https://github.com/BlueEventHorizon/AI-DevContainer
cd AI-DevContainer

# 2. Docker 環境を全自動セットアップ（Docker CLI + Colima + Buildx）
make install
```

これだけで完了です。Colima（Docker 実行環境）が自動的に起動します。

> **Homebrew がない場合**: 先に https://brew.sh の手順でインストールしてください。

> **詳しい解説**: `make install` の内部動作については [MAKEFILE_GUIDE.md](MAKEFILE_GUIDE.md) を参照してください。

### Linux の場合

1. **Docker Engine をインストール**
   - 公式ガイド: https://docs.docker.com/engine/install/

2. **リポジトリをクローン**
   ```bash
   git clone https://github.com/BlueEventHorizon/AI-DevContainer
   cd AI-DevContainer
   ```

これで環境構築は完了です。

---

## 使い方

### VS Code で使う（推奨）

VS Code を使うと、エディタとコンテナが統合され、最も快適に開発できます。

#### 事前準備: DevContainers 拡張機能のインストール

VS Code に **Dev Containers** 拡張機能が必要です（初回のみ）。

1. VS Code を開く
2. 拡張機能パネルを開く（`Cmd+Shift+X`）
3. 「**Dev Containers**」を検索
4. Microsoft 提供の「**Dev Containers**」をインストール

または [マーケットプレイス](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) から直接インストールできます。

#### コンテナを起動する

1. **VS Code でプロジェクトフォルダを開く**

   ```bash
   code AI-DevContainer
   ```

2. **コンテナで再度開く**

   VS Code の右下に以下の通知が表示されます：

   ```
   ファイルに開発コンテナーの構成ファイルが含まれています
   [コンテナーで再度開く]  [ボリュームでクローン]  [再表示しない...]
   ```

   **「コンテナーで再度開く」** をクリックしてください。

   > 通知が表示されない場合は、コマンドパレット（`Cmd+Shift+P`）を開き、「**Dev Containers: Reopen in Container**」を検索して実行してください。

3. **初回はビルドが実行される**

   初回はコンテナイメージのビルドが行われるため、数分かかります（2回目以降はキャッシュが効くため高速です）。VS Code の左下に進捗が表示されます。

4. **接続を確認する**

   ビルドが完了すると、VS Code がコンテナに接続された状態で再起動します。
   左下のステータスバーに **「Dev Container: ai-dev-container」** と表示されていれば成功です。

#### コンテナ内でターミナルを使う

メニューの `Terminal` → `New Terminal`、またはショートカット `` Cmd+` `` でターミナルを開きます。

```
/workspace $
```

このプロンプトが表示されていれば、コンテナ内のシェルです。ここで AI ツールを実行できます。

```bash
# Codex が使えることを確認
codex --help
```

#### コンテナを終了する

VS Code のコマンドパレット（`Cmd+Shift+P`）から「**Dev Containers: Reopen Folder Locally**」を実行すると、ローカル環境に戻ります。

---

### ターミナルから使う

VS Code を使わず、ターミナルから直接コンテナを操作することもできます。

#### 方法 1: 起動スクリプトを使う（簡単）

プロジェクトに同梱の `start-container.sh` を使います。

```bash
# コンテナを起動（初回は自動でイメージをビルド）
./start-container.sh

# イメージを強制的に再ビルドして起動
./start-container.sh --rebuild

# ヘルプを表示
./start-container.sh --help
```

起動すると、コンテナ内のシェルに入ります：

```
/workspace $
```

`exit` でコンテナから抜けます（コンテナは自動削除されます）。

#### 方法 2: Docker コマンドを直接使う

```bash
# イメージをビルド（初回のみ）
docker build -t ai-devcontainer -f .devcontainer/Dockerfile .

# コンテナを起動してシェルに入る
docker run -it --rm \
  -v "$(pwd)":/workspace \
  -w /workspace \
  ai-devcontainer sh -l
```

> **`sh -l` について**: `-l` はログインシェルを意味します。これにより `~/.profile` が読み込まれ、`codex` コマンドに PATH が通ります。`-l` を付けないと `codex: not found` になるので注意してください。

---

## AI ツールの使い方

### OpenAI Codex（コンテナ内）

コンテナ内のターミナルから `codex` コマンドで利用します。

```bash
# ヘルプを表示
codex --help

# 対話モードで起動
codex

# プロンプトを直接指定して実行
codex "このプロジェクトの構造を説明して"

# コードレビューを実行
codex review
```

> **注意**: Codex の利用には OpenAI の API キーが必要です。初回実行時に `codex login` で認証を行ってください。

### Claude Code（ホスト側 VS Code 拡張）

Claude Code は VS Code の拡張機能 **Anthropic.claude-code** としてホスト側で動作します。
DevContainer に接続した状態で VS Code から直接利用できます。

コンテナ内にはインストールされないため、ターミナルから `claude` コマンドは使えません。

> **拡張機能の自動推奨**: DevContainer に接続すると、`Anthropic.claude-code` 拡張のインストールが自動的に推奨されます（`.devcontainer/devcontainer.json` で設定済み）。

---

## 既存プロジェクトへの導入

この AI DevContainer 環境を、既存のプロジェクトに追加できます。

### 自動インストール（推奨）

```bash
# AI-DevContainer リポジトリのディレクトリで実行
./install-devcontainer.sh /path/to/your/project

# 既存ファイルをバックアップしながらインストール
./install-devcontainer.sh --backup /path/to/your/project
```

スクリプトは以下の **2つのファイルだけ** をコピーします：

| ステップ | コピー対象 | 必須/任意 | 説明 |
| --- | --- | --- | --- |
| [1/2] | `.devcontainer/` | 必須 | Dockerfile と devcontainer.json |
| [2/2] | `start-container.sh` | 任意 | ターミナルからの起動用スクリプト |

### 手動インストール

手動で行う場合は、以下をコピーしてください：

1. **`.devcontainer/`** ディレクトリ全体（必須）
2. **`start-container.sh`**（ターミナルから使う場合）

コピー後、対象プロジェクトを VS Code で開き、「Dev Containers: Reopen in Container」を実行すれば利用開始できます。

---

## コンテナの管理

### Docker 環境の起動・停止（macOS / Colima）

```bash
# Colima を起動（Docker 環境が使えるようになる）
colima start

# Colima を停止
colima stop
```

### コンテナイメージの再ビルド

AI ツールを更新したい場合や、Dockerfile を変更した場合はイメージを再ビルドします。

**VS Code の場合:**
- コマンドパレット（`Cmd+Shift+P`）→「**Dev Containers: Rebuild Container**」

**ターミナルの場合:**
```bash
./start-container.sh --rebuild
```

### Docker 環境の完全削除（macOS）

```bash
make uninstall
```

Colima、Docker CLI、Buildx プラグインがすべて削除されます。

---

## ファイル構成

```
AI-DevContainer/
├── .devcontainer/
│   ├── Dockerfile           # コンテナイメージの定義（Alpine Linux + Codex）
│   └── devcontainer.json    # VS Code DevContainer の設定
├── start-container.sh       # ターミナルからコンテナを起動するスクリプト
├── install-devcontainer.sh  # 既存プロジェクトへのインストールスクリプト
├── Makefile                 # macOS 向け Docker 環境の自動セットアップ
├── MAKEFILE_GUIDE.md        # Makefile の詳しい解説
├── CLAUDE.md                # Claude Code 向けのプロジェクト情報
└── README.md                # このファイル
```

---

## トラブルシューティング

### 「Docker is not running」と表示される

Docker（Colima）が起動していません。

```bash
# macOS の場合
colima start

# Linux の場合
sudo systemctl start docker
```

### コンテナ内で `codex: not found` と表示される

ログインシェルで起動していない可能性があります。

```bash
# sh -l（ログインシェル）で起動し直す
sh -l

# PATH が通っているか確認
which codex
```

`start-container.sh` または VS Code の DevContainer 機能を使えば、自動的にログインシェルで起動します。

### VS Code で「Reopen in Container」が表示されない

- **Dev Containers 拡張機能** がインストールされているか確認してください
- コマンドパレット（`Cmd+Shift+P`）から手動で「Dev Containers: Reopen in Container」を実行できます
- `.devcontainer/` ディレクトリがプロジェクトルートに存在するか確認してください

### コンテナのビルドが失敗する

ネットワーク接続を確認し、再ビルドしてください：

```bash
# キャッシュなしで再ビルド
docker build --no-cache -t ai-devcontainer -f .devcontainer/Dockerfile .
```

### macOS で `make install` が失敗する

Homebrew がインストールされているか確認してください：

```bash
brew --version
```

Homebrew がない場合は、先に https://brew.sh の手順でインストールしてください。

---

## 参考情報

- [MAKEFILE_GUIDE.md](MAKEFILE_GUIDE.md) — macOS での Colima セットアップの詳しい解説
- [CLAUDE.md](CLAUDE.md) — Claude Code 向けのプロジェクト情報
- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers) — DevContainers の公式ドキュメント
- [OpenAI Codex](https://github.com/openai/codex) — Codex の公式リポジトリ
