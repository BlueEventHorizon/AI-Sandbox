# AI Sandbox Dockerfile
# Ubuntu 24.04 ベース + Claude Code / OpenAI Codex ネイティブバイナリ
FROM ubuntu:24.04

# pipefail を有効化（パイプの途中で失敗しても検出する）
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# 必要パッケージのインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    ripgrep \
    bash \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 非 root ユーザー devuser を作成し、/workspace の所有権を付与
RUN useradd -m -s /bin/bash devuser && \
    mkdir -p /workspace && \
    chown -R devuser:devuser /workspace

WORKDIR /workspace

# devuser に切り替え
USER devuser

# PATH を設定（全シェル種別に適用）
ENV PATH="/home/devuser/.local/bin:$PATH"

# Claude Code を公式インストーラーでインストール
RUN curl -fsSL https://claude.ai/install.sh | bash

# OpenAI Codex を GitHub Releases から glibc バイナリとしてインストール
RUN ARCH=$(dpkg --print-architecture) && \
    case "${ARCH}" in \
      amd64) CODEX_ARCH="x86_64-unknown-linux-gnu" ;; \
      arm64) CODEX_ARCH="aarch64-unknown-linux-gnu" ;; \
      *) echo "Unsupported architecture: ${ARCH}" >&2 && exit 1 ;; \
    esac && \
    mkdir -p "$HOME/.local/bin" && \
    curl -fsSL -o /tmp/codex.tar.gz \
        "https://github.com/openai/codex/releases/latest/download/codex-${CODEX_ARCH}.tar.gz" && \
    tar xz -C /tmp -f /tmp/codex.tar.gz && \
    mv "/tmp/codex-${CODEX_ARCH}" "$HOME/.local/bin/codex" && \
    chmod +x "$HOME/.local/bin/codex" && \
    rm /tmp/codex.tar.gz
