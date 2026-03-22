FROM node:24-alpine

# Claude Code のネイティブインストールに必要なパッケージ
RUN apk add --no-cache libgcc libstdc++ ripgrep curl bash

# workspace ディレクトリを作成して node ユーザーの所有にする
RUN mkdir -p /workspace && chown -R node:node /workspace

WORKDIR /workspace

# node ユーザーに切り替え
USER node

# Claude Code をネイティブインストール（node ユーザーとして）
RUN curl -fsSL https://claude.ai/install.sh | bash

# シェル設定にエイリアスとPATHを追加
RUN echo 'export PATH="$HOME/.claude/local/bin:./node_modules/.bin:$PATH"' >> ~/.profile && \
    echo 'export USE_BUILTIN_RIPGREP=0' >> ~/.profile && \
    echo 'alias ll="ls -la"' >> ~/.profile && \
    echo 'alias gemini="npx gemini"' >> ~/.profile && \
    echo 'alias codex="npx codex"' >> ~/.profile
