FROM alpine:3.21

# Claude Code のネイティブインストールに必要なパッケージ
RUN apk add --no-cache libgcc libstdc++ ripgrep curl bash

# 非 root ユーザー devuser を作成し、/workspace の所有権を付与
RUN adduser -D devuser && \
    mkdir -p /workspace && \
    chown -R devuser:devuser /workspace

WORKDIR /workspace

# devuser に切り替え
USER devuser

# Claude Code を公式インストーラーでインストール（~/.local/bin/claude に配置される）
RUN curl -fsSL https://claude.ai/install.sh | bash

# OpenAI Codex を GitHub Releases から musl バイナリとしてインストール（~/.local/bin/codex に配置）
# ビルド時に uname -m でアーキテクチャを検出し、x86_64 または aarch64 の musl バイナリを選択する
RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
      x86_64|aarch64) ;; \
      *) echo "Unsupported architecture: $ARCH" >&2 && exit 1 ;; \
    esac && \
    mkdir -p "$HOME/.local/bin" && \
    curl -fsSL -o /tmp/codex.tar.gz \
        "https://github.com/openai/codex/releases/latest/download/codex-${ARCH}-unknown-linux-musl.tar.gz" && \
    tar xz -C "$HOME/.local/bin" -f /tmp/codex.tar.gz && \
    chmod +x "$HOME/.local/bin/codex" && \
    rm /tmp/codex.tar.gz

# PATH と USE_BUILTIN_RIPGREP を設定
# ENV はログイン・非ログイン・インタラクティブ・非インタラクティブすべてのシェルに適用される
ENV PATH="/home/devuser/.local/bin:$PATH"
ENV USE_BUILTIN_RIPGREP=0

# ログインシェル用に ~/.profile にも設定（sh -l 等の互換性のため）
RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile && \
    echo 'export USE_BUILTIN_RIPGREP=0' >> ~/.profile
