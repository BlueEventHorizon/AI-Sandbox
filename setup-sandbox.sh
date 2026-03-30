#!/bin/bash
# setup-sandbox.sh — AI Sandbox エントリポイント
# 使い方:
#   ./setup-sandbox.sh <ターゲットプロジェクトのパス>   # ターミナル起動
#   ./setup-sandbox.sh --vscode <パス>                 # VS Code 用 .devcontainer/ を配置
#   ./setup-sandbox.sh --rebuild <パス>                # イメージを強制再ビルドして起動
#   ./setup-sandbox.sh -h | --help                     # ヘルプ表示

set -euo pipefail

# --- 定数 ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCKERFILE_PATH="${SCRIPT_DIR}/.devcontainer/Dockerfile"
DEVCONTAINER_DIR="${SCRIPT_DIR}/.devcontainer"
IMAGE_NAME="ai-sandbox"

# --- ヘルプ ---
usage() {
    cat <<EOF
使い方:
  $(basename "$0") [OPTIONS] <ターゲットプロジェクトのパス>

OPTIONS:
  --rebuild    イメージを強制再ビルドしてからコンテナを起動する
  --vscode     ターゲットプロジェクトに .devcontainer/ を配置する（コンテナは起動しない）
  -h, --help   この使い方を表示する

例:
  $(basename "$0") ~/projects/my-app
  $(basename "$0") --rebuild ~/projects/my-app
  $(basename "$0") --vscode ~/projects/my-app
EOF
}

# --- オプション解析 ---
MODE="run"    # run | vscode
REBUILD=false
TARGET_PATH=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        --rebuild)
            REBUILD=true
            shift
            ;;
        --vscode)
            MODE="vscode"
            shift
            ;;
        -*)
            echo "エラー: 不明なオプション: $1" >&2
            usage >&2
            exit 1
            ;;
        *)
            if [[ -n "${TARGET_PATH}" ]]; then
                echo "エラー: ターゲットパスは1つだけ指定してください。" >&2
                usage >&2
                exit 1
            fi
            TARGET_PATH="$1"
            shift
            ;;
    esac
done

# --- ターゲットパスの確認 ---
if [[ -z "${TARGET_PATH}" ]]; then
    echo "エラー: ターゲットプロジェクトのパスを指定してください。" >&2
    usage >&2
    exit 1
fi

# 絶対パスに変換
_orig_target="${TARGET_PATH}"
TARGET_PATH="$(cd "${TARGET_PATH}" 2>/dev/null && pwd)" || {
    echo "エラー: パスが存在しません: ${_orig_target}" >&2
    exit 1
}

# git リポジトリ確認
if ! git -C "${TARGET_PATH}" rev-parse --git-dir > /dev/null 2>&1; then
    echo "エラー: 指定したパスは git リポジトリではありません: ${TARGET_PATH}" >&2
    exit 1
fi

# --- VS Code 配置モード ---
if [[ "${MODE}" == "vscode" ]]; then
    TARGET_DEVCONTAINER="${TARGET_PATH}/.devcontainer"

    if [[ -d "${TARGET_DEVCONTAINER}" ]]; then
        echo ".devcontainer/ が既に存在します: ${TARGET_DEVCONTAINER}"
        read -r -p "上書きしますか？ [y/N] " answer
        case "${answer}" in
            [yY]|[yY][eE][sS]) ;;
            *)
                echo "キャンセルしました。"
                exit 0
                ;;
        esac
    fi

    cp -r "${DEVCONTAINER_DIR}" "${TARGET_DEVCONTAINER}"
    echo "完了: .devcontainer/ を配置しました。"
    echo "VS Code でプロジェクトを開き、「Reopen in Container」を実行してください。"
    exit 0
fi

# --- ターミナル起動モード ---

# Docker インストール確認
if ! command -v docker > /dev/null 2>&1; then
    echo "エラー: Docker がインストールされていません。" >&2
    echo "macOS の場合: make install を実行してください。" >&2
    exit 1
fi

# Docker 起動確認
if ! docker info > /dev/null 2>&1; then
    echo "エラー: Docker が起動していません。" >&2
    echo "macOS の場合: colima start --memory 4 を実行してください。" >&2
    exit 1
fi

# Dockerfile 確認
if [[ ! -f "${DOCKERFILE_PATH}" ]]; then
    echo "エラー: Dockerfile が見つかりません: ${DOCKERFILE_PATH}" >&2
    exit 1
fi

# イメージ存在確認
IMAGE_EXISTS=false
if docker image inspect "${IMAGE_NAME}" > /dev/null 2>&1; then
    IMAGE_EXISTS=true
fi

# イメージビルド
if [[ "${REBUILD}" == true ]] || [[ "${IMAGE_EXISTS}" == false ]]; then
    if [[ "${REBUILD}" == true ]]; then
        echo "イメージを再ビルドします..."
    else
        echo "イメージが見つかりません。ビルドを開始します..."
    fi

    if ! docker build -t "${IMAGE_NAME}" "${DEVCONTAINER_DIR}"; then
        echo "エラー: イメージのビルドに失敗しました。" >&2
        exit 1
    fi
fi

# プロジェクト名（Volume 命名用: basename + フルパスハッシュで一意性を確保）
PROJECT_NAME="$(basename "${TARGET_PATH}")-$(echo -n "${TARGET_PATH}" | shasum -a 256 | cut -c1-8)"
VOLUME_NAME="${IMAGE_NAME}-claude-${PROJECT_NAME}"

# コンテナ起動
echo "コンテナを起動します: ${TARGET_PATH}"
docker run -it --rm \
    -v "${TARGET_PATH}:/workspace" \
    -v "${VOLUME_NAME}:/home/devuser/.claude" \
    -w /workspace \
    -e OPENAI_API_KEY \
    -e ANTHROPIC_API_KEY \
    "${IMAGE_NAME}" bash -l
