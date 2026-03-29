# FNC-001 DevContainer 環境構築（VS Code 連携） 要件定義書

## 概要

`setup-sandbox.sh --vscode` でターゲットの git プロジェクトに `.devcontainer/` を配置し、VS Code の DevContainers 拡張機能と連携してコンテナ環境を起動する。コンテナ内で Claude Code と OpenAI Codex が即時利用可能な状態となる。

**優先度**: 2（FNC-002 / FNC-003 の次に実装）

## 前提条件

- Docker（または互換ランタイム）が起動していること
- VS Code と DevContainers 拡張機能がインストールされていること
- AI Sandbox リポジトリがクローン済みであること

## 要件一覧

### `.devcontainer/` 配置要件

- `setup-sandbox.sh --vscode <ターゲットパス>` でターゲットプロジェクトに `.devcontainer/` を配置する
- 配置されるファイル: `Dockerfile`、`devcontainer.json`
- ターゲットに既に `.devcontainer/` が存在する場合は確認を求める

### コンテナ環境要件

- ベースイメージとして Ubuntu 24.04 を使用する（glibc 環境。Claude Code のネイティブバイナリが動作するため）
- コンテナ内の実行ユーザーは非 root ユーザーとする
- ターゲットプロジェクトがコンテナ内 `/workspace` にマウントされること

### AI コーディングアシスタントのプリインストール要件

- Claude Code と OpenAI Codex がコンテナイメージのビルド時にネイティブバイナリとしてインストールされる
- コンテナ起動時に追加のインストール処理を必要としない
- npm / Node.js は使用しない
- ツールの更新はコンテナイメージの再ビルドで行う

### VS Code 連携要件

- VS Code でターゲットプロジェクトを開いた際に、DevContainer での再オープンを提案する
- コンテナ接続後、統合ターミナルからコンテナ内のシェルを利用できる
- 統合ターミナルから `claude` および `codex` コマンドが実行できること
- Claude Code VS Code 拡張（`Anthropic.claude-code`）を自動推奨する

### 対応プラットフォーム要件

- 以下の OS 環境でコンテナが正常に起動し、AI コーディングアシスタントが動作すること:
  - macOS（Intel / Apple Silicon）
  - Linux（x86_64 / arm64）
- 各 OS で同一の Dockerfile からビルドしたイメージが同一の動作をすること

### エラーケース

| 条件 | 動作 |
| --- | --- |
| Docker が起動していない | DevContainer の起動に失敗する（VS Code がエラーを表示） |
| DevContainers 拡張機能が未インストール | DevContainer の認識・起動ができない |
| ターゲットに既に `.devcontainer/` が存在する | 上書きの確認を求める |

## 未確定事項

| ID | 内容 | 期限 |
| --- | --- | --- |
| （なし） | | |

## 変更履歴

| 日付 | 変更者 | 内容 |
| --- | --- | --- |
| 2026-03-21 | AI | 既存ソースコードから初版作成 |
| 2026-03-29 | AI | 全面書き換え: Ubuntu ベース、`setup-sandbox.sh --vscode` 方式、Claude Code コンテナ内復帰 |
