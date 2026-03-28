#!/bin/sh

# AI DevContainer 起動スクリプト
# コンテナを起動してシェルに入ります

set -e

# 色定義
YELLOW='\033[33m'
GREEN='\033[32m'
RED='\033[31m'
RESET='\033[0m'

IMAGE_NAME="ai-devcontainer"
DOCKERFILE_PATH=".devcontainer/Dockerfile"

# 使用方法を表示
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --rebuild       Force rebuild the DevContainer image"
    echo "  -h, --help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0              Start DevContainer (build if needed)"
    echo "  $0 --rebuild    Rebuild and start DevContainer"
}

# 引数解析
REBUILD=false

while [ $# -gt 0 ]; do
    case "$1" in
        --rebuild)
            REBUILD=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "${RED}Unknown option: $1${RESET}"
            usage
            exit 1
            ;;
    esac
done

# Docker がインストールされているか確認
if ! command -v docker >/dev/null 2>&1; then
    echo "${RED}❌ Error: Docker is not installed.${RESET}"
    echo "Please install Docker first."
    exit 1
fi

# Docker が起動しているか確認
if ! docker info >/dev/null 2>&1; then
    echo "${RED}❌ Error: Docker is not running.${RESET}"
    echo "Please start Docker (or Colima)."
    exit 1
fi

# DevContainer を使用する場合
echo "${GREEN}Using DevContainer...${RESET}"

# Dockerfile の存在確認
if [ ! -f "$DOCKERFILE_PATH" ]; then
    echo "${RED}❌ Error: $DOCKERFILE_PATH not found.${RESET}"
    echo "Are you in the project root directory?"
    exit 1
fi

# イメージが存在するか確認
IMAGE_EXISTS=$(docker images -q "$IMAGE_NAME" 2>/dev/null)

if [ -z "$IMAGE_EXISTS" ] || [ "$REBUILD" = true ]; then
    if [ "$REBUILD" = true ]; then
        echo "${YELLOW}Rebuilding container image...${RESET}"
    else
        echo "${YELLOW}Container image not found. Building...${RESET}"
    fi

    if docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" .; then
        echo "${GREEN}✅ Image built successfully.${RESET}"
    else
        echo "${RED}❌ Failed to build image.${RESET}"
        exit 1
    fi
else
    echo "${GREEN}✅ Image found: $IMAGE_NAME${RESET}"
fi

# コンテナを起動
echo "${GREEN}Starting container...${RESET}"

docker run -it --rm \
    -v "$(pwd)":/workspace \
    -w /workspace \
    "$IMAGE_NAME" sh -l
