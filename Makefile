.DEFAULT_GOAL := help
.PHONY: help install uninstall detect-platform check-docker check-colima check-buildx

# 色定義
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m

# デフォルトターゲット: ヘルプを表示
help:
	@echo "Available targets:"
	@echo "  make install    - Install and start Docker/Colima environment"
	@echo "  make uninstall  - Uninstall all components"

# プラットフォーム検出
detect-platform:
	@if [ "$$(uname)" != "Darwin" ]; then \
		printf "$(RED)❌ Error: This Makefile is designed for macOS.$(RESET)\n"; \
		printf "$(RED)   Your platform: $$(uname)$(RESET)\n"; \
		exit 1; \
	fi
	@if ! command -v brew &>/dev/null; then \
		printf "$(RED)❌ Error: Homebrew is not installed.$(RESET)\n"; \
		printf "$(RED)   Install from: https://brew.sh$(RESET)\n"; \
		exit 1; \
	fi

# メイン: Colima, Docker, Buildx のセットアップ
install: detect-platform check-docker check-colima check-buildx
	@printf "$(YELLOW)Starting Colima...$(RESET)\n"
	@if colima status &>/dev/null; then \
		printf "$(YELLOW)Colima is already running.$(RESET)\n"; \
	else \
		if colima start --memory 4; then \
			printf "$(YELLOW)Colima started successfully.$(RESET)\n"; \
		else \
			printf "$(RED)❌ Failed to start Colima.$(RESET)\n"; \
			exit 1; \
		fi; \
	fi
	@printf "$(YELLOW)✅ Setup complete!$(RESET)\n"
	@printf "$(YELLOW)Next: See 'Usage' section in README.md$(RESET)\n"

# Docker がインストールされているかチェック
check-docker:
	@if ! command -v docker &>/dev/null; then \
		printf "$(YELLOW)Docker not found. Installing...$(RESET)\n"; \
		if brew install docker; then \
			printf "$(YELLOW)Docker installed successfully.$(RESET)\n"; \
		else \
			printf "$(RED)❌ Failed to install Docker.$(RESET)\n"; \
			exit 1; \
		fi; \
	else \
		printf "$(YELLOW)Docker is already installed.$(RESET)\n"; \
	fi

# Colima がインストールされているかチェック
check-colima:
	@if ! command -v colima &>/dev/null; then \
		printf "$(YELLOW)Colima not found. Installing...$(RESET)\n"; \
		if brew install colima; then \
			printf "$(YELLOW)Colima installed successfully.$(RESET)\n"; \
		else \
			printf "$(RED)❌ Failed to install Colima.$(RESET)\n"; \
			exit 1; \
		fi; \
	else \
		printf "$(YELLOW)Colima is already installed.$(RESET)\n"; \
	fi

# Buildx プラグインが存在するかチェック（アーキテクチャ自動検出）
check-buildx:
	@if [ ! -f "$$HOME/.docker/cli-plugins/docker-buildx" ]; then \
		printf "$(YELLOW)Docker buildx not found. Installing...$(RESET)\n"; \
		mkdir -p "$$HOME/.docker/cli-plugins"; \
		ARCH=$$(uname -m); \
		case $$ARCH in \
			x86_64) BUILDX_ARCH="darwin-amd64" ;; \
			arm64|aarch64) BUILDX_ARCH="darwin-arm64" ;; \
			*) printf "$(RED)❌ Unsupported architecture: $$ARCH$(RESET)\n"; exit 1 ;; \
		esac; \
		printf "$(YELLOW)Detected architecture: $$ARCH ($$BUILDX_ARCH)$(RESET)\n"; \
		LATEST_VERSION=$$(curl -fsSL https://api.github.com/repos/docker/buildx/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/' || echo "0.26.1"); \
		printf "$(YELLOW)Downloading buildx v$$LATEST_VERSION...$(RESET)\n"; \
		TMP_FILE=$$(mktemp); \
		if curl -fLo "$$TMP_FILE" "https://github.com/docker/buildx/releases/download/v$$LATEST_VERSION/buildx-v$$LATEST_VERSION.$$BUILDX_ARCH"; then \
			mv "$$TMP_FILE" "$$HOME/.docker/cli-plugins/docker-buildx" && \
			chmod +x "$$HOME/.docker/cli-plugins/docker-buildx" && \
			printf "$(YELLOW)Docker buildx installed successfully.$(RESET)\n"; \
		else \
			printf "$(RED)❌ Failed to download buildx. Please check your internet connection.$(RESET)\n"; \
			rm -f "$$TMP_FILE"; \
			exit 1; \
		fi; \
	else \
		printf "$(YELLOW)Docker buildx is already installed.$(RESET)\n"; \
	fi

# すべてをアンインストール
uninstall:
	@if command -v colima &>/dev/null; then \
		printf "$(YELLOW)Uninstalling Colima...$(RESET)\n"; \
		colima stop 2>/dev/null || true; \
		colima delete 2>/dev/null || true; \
		brew uninstall colima || true; \
		printf "$(YELLOW)Removing Colima data...$(RESET)\n"; \
		rm -rf ~/.colima 2>/dev/null || true; \
		printf "$(YELLOW)Colima uninstalled.$(RESET)\n"; \
	else \
		printf "$(YELLOW)Colima is not installed.$(RESET)\n"; \
	fi
	@if [ -f "$$HOME/.docker/cli-plugins/docker-buildx" ]; then \
		printf "$(YELLOW)Removing Docker buildx plugin...$(RESET)\n"; \
		rm -f "$$HOME/.docker/cli-plugins/docker-buildx"; \
		printf "$(YELLOW)Docker buildx uninstalled.$(RESET)\n"; \
	else \
		printf "$(YELLOW)Docker buildx plugin is not installed.$(RESET)\n"; \
	fi
	@if command -v docker &>/dev/null; then \
		printf "$(YELLOW)Uninstalling Docker...$(RESET)\n"; \
		brew uninstall docker || true; \
		printf "$(YELLOW)Docker uninstalled.$(RESET)\n"; \
	else \
		printf "$(YELLOW)Docker is not installed.$(RESET)\n"; \
	fi
	@printf "$(YELLOW)All components have been uninstalled.$(RESET)\n"
