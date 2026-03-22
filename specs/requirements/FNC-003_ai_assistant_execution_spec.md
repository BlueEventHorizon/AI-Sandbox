# FNC-003 AI コーディングアシスタント実行 要件定義書

## 概要

コンテナ環境内で Gemini CLI、Claude Code、OpenAI Codex の3つの AI コーディングアシスタントを実行できるようにする。

## 前提条件

- DevContainer またはコンソールコンテナが起動していること
- 各 AI コーディングアシスタントの API キーまたは認証が設定されていること（ツールごとに異なる）

## 要件一覧

### 対応ツール要件

以下の AI コーディングアシスタントが利用可能であること:

| ツール名 | パッケージ | コマンド |
| --- | --- | --- |
| Gemini CLI | @google/gemini-cli | `gemini` |
| Claude Code | @anthropic-ai/claude-code | `claude` |
| OpenAI Codex | @openai/codex | `codex` |

### 実行方法要件

各ツールは以下の方法で実行できること:

- **直接実行**: コマンド名で直接実行（エイリアス経由）
  - 例: `gemini --help`, `claude --help`, `codex --help`
- **npm script 経由**: npm run コマンドで実行
  - 例: `npm run gemini -- --help`
- **npx 経由**: npx コマンドで実行
  - 例: `npx gemini --help`

### バージョン管理要件

- 各ツールは package.json で latest を指定する
- コンテナ起動時に npm install が実行され、package-lock.json が存在しない場合はその時点の最新バージョンがインストールされる

### セキュリティ要件

- 各 AI コーディングアシスタントの API キー・認証情報はコンテナ環境変数または設定ファイルで管理し、リポジトリにコミットしない
- 認証情報を含むファイル（`.env` 等）は `.gitignore` に含める

### エラーケース

| 条件 | 動作 |
| --- | --- |
| npm install が失敗した場合 | コマンドが見つからず、ツールを実行できない |
| API キーが未設定の場合 | 各ツール固有の認証エラーを表示する |

## 未確定事項

| ID | 内容 | 期限 |
| --- | --- | --- |
| （なし） | | |

## 変更履歴

| 日付 | 変更者 | 内容 |
| --- | --- | --- |
| 2026-03-21 | AI | 既存ソースコードから初版作成 |
