# APP-001 AI DevContainer 要件定義書

## 概要

AI コーディングアシスタント（Gemini CLI、Claude Code、OpenAI Codex）を統合した、汎用的な Node.js 開発用 DevContainer 環境を提供する。コンテナ技術により、ローカル環境を汚さず、OS の違いを問わず統一された開発環境を素早く構築できる。

## 前提条件

- Docker（または互換ランタイム）が利用可能であること
- Node.js プロジェクトでの利用を想定

## プロジェクトの目的

- 開発者が AI コーディングアシスタントを手軽に利用できる環境を提供する（FNC-001, FNC-003）
- ローカル環境を汚さず、再現可能な開発環境を構築する（FNC-001, FNC-002）
- OS（macOS, Windows, Linux）に依存しない統一された環境を提供する（FNC-001, FNC-004）

## 主要機能一覧

| ID | 機能名 | 概要 |
| --- | --- | --- |
| FNC-001 | DevContainer 環境構築 | VS Code と連携した DevContainer 環境の構築・起動 |
| FNC-002 | コンテナ起動（コンソール） | VS Code なしでコンテナを起動し、シェルから利用する |
| FNC-003 | AI コーディングアシスタント実行 | Gemini CLI, Claude Code, OpenAI Codex の実行 |
| FNC-004 | macOS Docker 環境セットアップ | Colima を使った Docker 環境の自動セットアップ |
| FNC-005 | 既存プロジェクトへのインストール | 既存プロジェクトに AI DevContainer 環境を追加する |

## 用語定義

| 用語 | 定義 |
| --- | --- |
| AI コーディングアシスタント | 本プロジェクトが対象とする AI 開発支援ツール（Gemini CLI, Claude Code, OpenAI Codex）の正式な総称 |

## 対象ユーザー

- AI コーディングアシスタントを活用したい Node.js 開発者
- チーム開発で統一された開発環境を求める開発者
- macOS で Docker Desktop の代替を求める開発者

## 未確定事項

| ID | 内容 | 期限 |
| --- | --- | --- |
| （なし） | | |

## 変更履歴

| 日付 | 変更者 | 内容 |
| --- | --- | --- |
| 2026-03-21 | AI | 既存ソースコードから初版作成 |
