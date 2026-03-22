#!/bin/bash

# AI DevContainer インストールスクリプト
# このスクリプトは既存プロジェクトに AI DevContainer 環境をインストールします

set -e

# 色の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 使い方の表示
usage() {
    echo "使い方: $0 [OPTIONS] <target-directory>"
    echo ""
    echo "OPTIONS:"
    echo "  --backup    既存ファイルのバックアップを作成"
    echo "  --help      このヘルプを表示"
    echo ""
    echo "例:"
    echo "  $0 /path/to/your/project"
    echo "  $0 --backup /path/to/your/project"
    exit 1
}

# エラーメッセージ
error() {
    echo -e "${RED}エラー: $1${NC}" >&2
    exit 1
}

# 成功メッセージ
success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# 警告メッセージ
warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# 確認プロンプト
confirm() {
    read -p "$1 (y/n): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# オプション解析
BACKUP=false
TARGET_DIR=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --backup)
            BACKUP=true
            shift
            ;;
        --help)
            usage
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

# ターゲットディレクトリのチェック
if [ -z "$TARGET_DIR" ]; then
    error "ターゲットディレクトリを指定してください"
    usage
fi

if [ ! -d "$TARGET_DIR" ]; then
    error "ディレクトリが存在しません: $TARGET_DIR"
fi

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "AI DevContainer インストーラー"
echo "================================"
echo "ターゲット: $TARGET_DIR"
echo ""

# .devcontainer のコピー
echo "[1/4] .devcontainer ディレクトリをコピー中..."
if [ -d "$TARGET_DIR/.devcontainer" ]; then
    warning ".devcontainer ディレクトリが既に存在します"
    if $BACKUP; then
        BACKUP_NAME=".devcontainer.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$TARGET_DIR/.devcontainer" "$TARGET_DIR/$BACKUP_NAME"
        success "既存ディレクトリを $BACKUP_NAME にバックアップしました"
    elif confirm "上書きしますか？"; then
        rm -rf "$TARGET_DIR/.devcontainer"
    else
        error "インストールを中止しました"
    fi
fi
cp -r "$SCRIPT_DIR/.devcontainer" "$TARGET_DIR/"
success ".devcontainer をコピーしました"

# package.json の処理
echo ""
echo "[2/4] package.json を処理中..."
if [ -f "$TARGET_DIR/package.json" ]; then
    warning "package.json が既に存在します"

    # jq がインストールされているか確認
    if command -v jq &> /dev/null; then
        # devDependencies をマージ
        TEMP_FILE=$(mktemp)
        if jq -s '.[0] * {
            devDependencies: ((.[0].devDependencies // {}) + (.[1].devDependencies // {})),
            scripts: ((.[0].scripts // {}) + (.[1].scripts // {}))
        }' "$TARGET_DIR/package.json" "$SCRIPT_DIR/package.json" > "$TEMP_FILE" 2>/dev/null; then

            if $BACKUP; then
                cp "$TARGET_DIR/package.json" "$TARGET_DIR/package.json.backup.$(date +%Y%m%d_%H%M%S)"
                success "既存の package.json をバックアップしました"
            fi

            mv "$TEMP_FILE" "$TARGET_DIR/package.json"
            success "package.json をマージしました"
        else
            rm -f "$TEMP_FILE"
            warning "jq でのマージに失敗しました。手動で以下を package.json に追加してください:"
            echo ""
            echo "  devDependencies に追加:"
            echo "    \"@google/gemini-cli\": \"latest\","
            echo "    \"@openai/codex\": \"latest\""
            echo ""
            echo "  scripts に追加:"
            echo "    \"gemini\": \"gemini\","
            echo "    \"codex\": \"codex\""
            echo ""
            echo "  ※ Claude Code は Dockerfile 内でネイティブインストールされます"
        fi
    else
        warning "jq がインストールされていません。手動で以下を package.json に追加してください:"
        echo ""
        echo "  devDependencies:"
        echo "    \"@google/gemini-cli\": \"latest\","
        echo "    \"@openai/codex\": \"latest\""
        echo ""
        echo "  scripts:"
        echo "    \"gemini\": \"gemini\","
        echo "    \"codex\": \"codex\""
        echo ""
        echo "  ※ Claude Code は Dockerfile 内でネイティブインストールされます"
    fi
else
    cp "$SCRIPT_DIR/package.json" "$TARGET_DIR/"
    success "package.json をコピーしました"
fi

# .gitignore の処理
echo ""
echo "[3/4] .gitignore を確認中..."
if [ -f "$TARGET_DIR/.gitignore" ]; then
    if ! grep -q "node_modules/" "$TARGET_DIR/.gitignore"; then
        echo "node_modules/" >> "$TARGET_DIR/.gitignore"
        success ".gitignore に node_modules/ を追加しました"
    else
        success ".gitignore は既に node_modules/ を含んでいます"
    fi
else
    echo "node_modules/" > "$TARGET_DIR/.gitignore"
    success ".gitignore を作成しました"
fi

# start-container.sh のコピー
echo ""
echo "[4/5] start-container.sh をコピー中..."
if [ -f "$SCRIPT_DIR/start-container.sh" ]; then
    if [ -f "$TARGET_DIR/start-container.sh" ]; then
        warning "start-container.sh が既に存在します"
        if $BACKUP; then
            cp "$TARGET_DIR/start-container.sh" "$TARGET_DIR/start-container.sh.backup.$(date +%Y%m%d_%H%M%S)"
            success "既存の start-container.sh をバックアップしました"
        elif ! confirm "上書きしますか？"; then
            warning "start-container.sh のコピーをスキップしました"
        else
            cp "$SCRIPT_DIR/start-container.sh" "$TARGET_DIR/"
            chmod +x "$TARGET_DIR/start-container.sh"
            success "start-container.sh をコピーしました"
        fi
    else
        cp "$SCRIPT_DIR/start-container.sh" "$TARGET_DIR/"
        chmod +x "$TARGET_DIR/start-container.sh"
        success "start-container.sh をコピーしました"
    fi
else
    warning "start-container.sh が見つかりません"
fi

# Makefile のコピー（オプション）
echo ""
echo "[5/5] Makefile を確認中..."
if [ -f "$SCRIPT_DIR/Makefile" ]; then
    if confirm "Makefile をコピーしますか？（macOS ユーザーで Docker Desktop を使わない場合に有用）"; then
        if [ -f "$TARGET_DIR/Makefile" ] && $BACKUP; then
            cp "$TARGET_DIR/Makefile" "$TARGET_DIR/Makefile.backup.$(date +%Y%m%d_%H%M%S)"
            success "既存の Makefile をバックアップしました"
        fi
        cp "$SCRIPT_DIR/Makefile" "$TARGET_DIR/"
        success "Makefile をコピーしました"
    else
        echo "Makefile のコピーをスキップしました"
    fi
fi

# 完了メッセージ
echo ""
echo "================================"
success "インストールが完了しました！"
echo ""
echo "次のステップ:"
echo "1. VS Code でプロジェクトを開く"
echo "2. コマンドパレット (Cmd+Shift+P) を開く"
echo "3. 'Dev Containers: Reopen in Container' を実行"
echo ""
echo "詳細は README.md を参照してください。"
