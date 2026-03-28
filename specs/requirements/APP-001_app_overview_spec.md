# APP-001 AI DevContainer 要件定義書

## 概要

AI コーディングアシスタント（OpenAI Codex）をプリインストールした汎用開発用 DevContainer 環境を提供する。Claude Code はホスト側の VS Code 拡張として使用する。開発者はコンテナを起動するだけで、ローカル環境を汚さずに AI 支援開発を開始できる。

## 背景・動機

AI コーディングアシスタントは開発生産性を大幅に向上させるが、導入には以下の障壁がある:

- 各ツールのインストール手順が異なり、セットアップに時間がかかる
- ローカル環境にツールをインストールすると、バージョン競合や環境汚染が発生する
- チームメンバー間で環境差異が生じ、「自分の環境では動く」問題が起きる
- macOS では Docker Desktop がライセンス上の制約を持つ場合があり、代替手段の構築が煩雑

## 解決する問題

| 問題 | 対象者 |
| --- | --- |
| AI ツールのセットアップが煩雑で時間がかかる | 全開発者 |
| ローカル環境へのツールインストールによる環境汚染 | 全開発者 |
| チーム内での環境差異によるトラブル | チーム開発者 |
| macOS での Docker Desktop 代替構築の煩雑さ | macOS ユーザー |
| 既存プロジェクトへの AI 開発環境の追加が手作業 | 既存プロジェクトの開発者 |

## プロジェクトの目的

- コンテナ起動のみで AI コーディングアシスタントが利用可能な環境を提供する（FNC-001, FNC-003）
- ローカル環境を汚さず、再現可能な開発環境を構築する（FNC-001, FNC-002）
- macOS および Linux で統一された環境を提供する（FNC-001, FNC-004）
- 既存プロジェクトへの導入を自動化する（FNC-005）

## 成功基準

| 目的 | 成功基準 |
| --- | --- |
| AI ツールが即時利用可能 | コンテナ起動後、追加のインストール作業なしで `codex --help` が正常終了すること |
| 環境の再現性 | 同一の Dockerfile から異なるマシンでビルドしたイメージが同一のツールセットを含むこと |
| OS 対応 | macOS および Linux でコンテナが起動し、AI ツールが動作すること |
| 既存プロジェクトへの導入 | `install-devcontainer.sh` 実行後、対象プロジェクトで DevContainer が起動すること |
| macOS セットアップ自動化 | `make install` 実行のみで Docker 環境が利用可能になること |

## スコープ

### 対象範囲

- DevContainer 環境の構築・配布
- AI コーディングアシスタント（OpenAI Codex）のプリインストール。Claude Code はホスト側 VS Code 拡張として使用
- VS Code 連携およびターミナルからのコンテナ利用
- macOS 向け Docker 環境（Colima）の自動セットアップ
- 既存プロジェクトへのインストールスクリプト

### スコープ外

- Windows のサポート（Docker Desktop のライセンス制約のため）
- 各 AI コーディングアシスタントの API キー取得・認証設定手順
- AI コーディングアシスタントの使い方ガイド・チュートリアル
- CI/CD パイプラインへの統合
- コンテナ内でのアプリケーション開発用ランタイム・フレームワークの提供

## 対象ユーザー

| ユーザー像 | 前提知識 |
| --- | --- |
| AI コーディングアシスタントを活用したい開発者 | ターミナルの基本操作、Git の基本操作 |
| チーム開発で統一された開発環境を求める開発者 | Docker の基本概念（イメージ、コンテナ） |
| macOS で Docker Desktop の代替を求める開発者 | Homebrew の基本操作 |

## 対応プラットフォーム

| OS | Docker 環境 | セットアップ方法 |
| --- | --- | --- |
| macOS（Intel / Apple Silicon） | Colima | `make install` で自動セットアップ（FNC-004） |
| Linux（x86_64） | Docker Engine | Docker Engine の手動インストール |

### 必須ソフトウェアバージョン

| ソフトウェア | 最低バージョン | 備考 |
| --- | --- | --- |
| Docker Engine | 20.10 以上 | BuildKit サポートが必要なため |
| VS Code | DevContainers 拡張機能の要件に準じる | DevContainers 拡張機能が対応する VS Code バージョンに従う |

## 前提条件

- Docker Engine 20.10 以上がインストールされ、起動していること（macOS では Colima 経由）
- VS Code を利用する場合は DevContainers 拡張機能がインストールされていること
- 各 AI コーディングアシスタントの利用に必要な API キーまたは認証情報をユーザーが保有していること

## 環境構成

### コンテナ構成

- **ベースイメージ**: Alpine Linux（軽量）
- **実行ユーザー**: 非 root ユーザー（セキュリティ確保）
- **ワークスペース**: ホストのプロジェクトルートをコンテナ内にマウント

### プリインストール済みツール

| ツール | 役割 | インストール方式 |
| --- | --- | --- |
| OpenAI Codex | コンテナ内 AI コーディングアシスタント | ネイティブバイナリ（musl） |
| Claude Code | ホスト側 AI コーディングアシスタント | VS Code 拡張（`Anthropic.claude-code`） |

OpenAI Codex はコンテナイメージのビルド時にネイティブバイナリとしてインストールされる。Claude Code はホスト側の VS Code 拡張として動作し、コンテナ内にはインストールしない（Linux musl 非互換のため）。npm / Node.js は不要。

### 利用形態

```
開発者
  │
  ├─ VS Code ─── DevContainers 拡張機能 ─── コンテナ接続
  │   │                                       └── OpenAI Codex（コンテナ内）
  │   └── Claude Code（ホスト側 VS Code 拡張）
  │
  └─ ターミナル ── start-container.sh ─────── コンテナ接続（同上）
```

## 利用シナリオ

### シナリオ 1: macOS で初めから始める（Docker 環境なし）

| 手順 | 操作 | 備考 |
| --- | --- | --- |
| 1 | AI DevContainer リポジトリを任意の場所にクローン | インストール素材として使用 |
| 2 | `make install` を実行 | Colima + Docker CLI + Buildx が自動セットアップされる |
| 3 | シナリオ 3 または 4 へ進む | Docker 環境の準備が完了 |

### シナリオ 2: Linux で初めから始める（Docker 環境なし）

| 手順 | 操作 | 備考 |
| --- | --- | --- |
| 1 | Docker Engine をインストール | 手動セットアップ |
| 2 | AI DevContainer リポジトリを任意の場所にクローン | インストール素材として使用 |
| 3 | シナリオ 3 または 4 へ進む | Docker 環境の準備が完了 |

### シナリオ 3: AI DevContainer リポジトリ自体を開発環境として使う

Docker 環境が既にある前提。

| 手順 | 操作 | 備考 |
| --- | --- | --- |
| 1 | AI DevContainer リポジトリを任意の場所にクローン | このリポジトリ自体がワークスペースになる |
| 2 | VS Code で開いて「Reopen in Container」を実行 | またはターミナルから `./start-container.sh` |
| 3 | `claude` や `codex` を実行 | 追加インストール不要 |

### シナリオ 4: 既存プロジェクトに AI DevContainer を導入する

Docker 環境が既にある前提。

| 手順 | 操作 | 備考 |
| --- | --- | --- |
| 1 | AI DevContainer リポジトリを任意の一時的な場所にクローン | インストール素材として使用 |
| 2 | `./install-devcontainer.sh /path/to/your/project` を実行 | `.devcontainer/` と起動スクリプトがコピーされる |
| 3 | 対象プロジェクトで VS Code「Reopen in Container」を実行 | またはターミナルから `./start-container.sh` |
| 4 | クローンした AI DevContainer リポジトリを削除 | インストール完了後は不要 |

### シナリオ 5: 日常利用（2回目以降）

| 手順 | 操作 | 備考 |
| --- | --- | --- |
| 1 | Docker を起動 | macOS: `colima start` |
| 2 | VS Code で「Reopen in Container」を実行 | またはターミナルから `./start-container.sh` |
| 3 | AI コーディングアシスタントを使って開発 | |
| 4 | Docker を停止 | macOS: `colima stop` |

## シナリオ⇔機能要件 対応表

| シナリオ | 主要手順 | 対応する機能要件 |
| --- | --- | --- |
| シナリオ 1: macOS 初回セットアップ | `make install` で Docker 環境を構築 | FNC-004 |
| シナリオ 2: Linux 初回セットアップ | Docker Engine の手動インストール | （手動インストールを前提） |
| シナリオ 3: リポジトリ自体を開発環境として使用 | VS Code「Reopen in Container」で起動 | FNC-001 |
| シナリオ 3: リポジトリ自体を開発環境として使用 | `./start-container.sh` で起動 | FNC-002 |
| シナリオ 3: リポジトリ自体を開発環境として使用 | `claude` や `codex` を実行 | FNC-003 |
| シナリオ 4: 既存プロジェクトへの導入 | `./install-devcontainer.sh` を実行 | FNC-005 |
| シナリオ 4: 既存プロジェクトへの導入 | 対象プロジェクトで DevContainer 起動 | FNC-001, FNC-002 |
| シナリオ 5: 日常利用 | Docker 起動後、DevContainer またはスクリプトで接続 | FNC-001, FNC-002, FNC-003 |

## 主要機能一覧

| ID | 機能名 | 概要 |
| --- | --- | --- |
| FNC-001 | DevContainer 環境構築 | VS Code と連携した DevContainer 環境の構築・起動 |
| FNC-002 | コンテナ起動（コンソール） | VS Code なしでコンテナを起動し、シェルから利用する |
| FNC-003 | AI コーディングアシスタント実行 | OpenAI Codex（コンテナ内）、Claude Code（ホスト側 VS Code 拡張） |
| FNC-004 | macOS Docker 環境セットアップ | Colima を使った Docker 環境の自動セットアップ |
| FNC-005 | 既存プロジェクトへのインストール | 既存プロジェクトに AI DevContainer 環境を追加する |

## 外部依存

| 依存先 | 用途 | 提供停止時の影響 |
| --- | --- | --- |
| GitHub Releases（openai/codex） | OpenAI Codex のインストール | Dockerfile を修正し、手動でバイナリを取得する必要がある |
| Homebrew | macOS での Colima / Docker CLI インストール | macOS 自動セットアップ（FNC-004）が利用不可。手動インストールで代替 |
| Docker Hub（alpine） | ベースイメージ | 別のレジストリまたはローカルキャッシュから取得する必要がある |

## 制約事項

| 制約 | 理由 |
| --- | --- |
| ベースイメージに Alpine Linux を採用 | 軽量さを優先。glibc 依存のバイナリは直接利用できないため、musl 互換のものを使用する |
| npm / Node.js は使用しない | 全ツールがネイティブバイナリで動作するため不要。依存関係を最小化する |
| Docker Desktop は使用しない | ライセンス制約のため。macOS では Colima、Linux では Docker Engine を使用する |
| macOS 自動セットアップは Homebrew を前提とする | Colima / Docker CLI のインストールに Homebrew を使用するため |
| Linux の Docker 環境自動セットアップは未提供 | Docker Engine の手動インストールを前提とする |
| Windows はスコープ外 | Docker Desktop のライセンス制約に加え、OSS 代替の検証コストが高いため |

## 既知のリスク

| リスク | 影響度 | 対策 |
| --- | --- | --- |
| AI ツールのインストーラー仕様変更 | 高 | Dockerfile のビルドが失敗する。インストーラー URL やオプションを追従して修正する |
| Alpine Linux での AI ツール互換性問題 | 中 | musl 環境固有の問題が発生する可能性がある。報告があればベースイメージの変更（Debian 系）を検討する。Claude Code は Linux musl 非互換のため除外済み |
| AI ツールの API キー認証方式の変更 | 低 | ツール固有の問題であり、本プロジェクトのスコープ外。README で注意喚起する |

## 用語定義

| 用語 | 定義 |
| --- | --- |
| AI コーディングアシスタント | 本プロジェクトが対象とする AI 開発支援ツール（Claude Code, OpenAI Codex）の正式な総称 |
| DevContainer | VS Code の Dev Containers 拡張機能が管理するコンテナ開発環境 |
| Colima | macOS / Linux 向けの Docker ランタイム（Docker Desktop の OSS 代替） |

## 関連文書

| 文書 | 内容 |
| --- | --- |
| FNC-001 ~ FNC-005 | 各機能の詳細要件定義書 |
| specs/app_overview_writing_standard.md | APP概要要件定義書の記載基準 |

## 未確定事項

| ID | 内容 | 期限 |
| --- | --- | --- |
| （なし） | | |

## 変更履歴

| 日付 | 変更者 | 内容 |
| --- | --- | --- |
| 2026-03-21 | AI | 既存ソースコードから初版作成 |
| 2026-03-22 | AI | 記載基準に基づき全面改訂。背景・成功基準・スコープ・外部依存・制約・リスクを追加 |
| 2026-03-22 | AI | 必須ソフトウェアバージョン要件を追加。シナリオ⇔機能要件対応表を追加 |
| 2026-03-28 | AI | Docker Desktop 削除、Windows スコープ外に変更。Gemini CLI 削除、Node.js/npm 不要化 |
| 2026-03-28 | AI | Claude Code をコンテナから除外（Linux musl 非互換）。ホスト側 VS Code 拡張として使用する方針に変更 |
