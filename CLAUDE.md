# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a general-purpose VS Code DevContainer sample project for AI-assisted development. The project provides a consistent development environment using DevContainers with Alpine Linux and native binaries, allowing developers to use AI tools (Claude Code, OpenAI Codex) without polluting their local environment. npm / Node.js is not used.

## DevContainer Architecture

The project uses a minimal Alpine Linux container with native binaries:

- **Base Image**: `alpine:3.21` (.devcontainer/Dockerfile)
- **Remote User**: `devuser` (non-root user for security)
- **Workspace**: `/workspace` (mounted from project root)
- **Pre-installed Tools**: Claude Code (native binary via official installer), OpenAI Codex (musl binary from GitHub Releases)
- **VS Code Extensions**: `Anthropic.claude-code`
- **PATH**: `~/.local/bin` (set via `ENV` instruction and `~/.profile`)
- **Environment Variable**: `USE_BUILTIN_RIPGREP=0`

All tools are pre-installed during the Docker image build. No `postCreateCommand` or runtime installation steps are needed. There is no `package.json` or `node_modules` in this project.

## Common Commands

### Using AI Coding Assistants

#### Claude Code

```bash
claude --help
```

#### OpenAI Codex

```bash
codex --help
```

### Container Management (macOS alternative to Docker Desktop)

```bash
# Initial setup (installs Docker, Colima, buildx plugin)
make install

# Start Colima (after initial setup, 4GiB or more memory required)
colima start --memory 4

# Stop Colima
colima stop

# Uninstall all components
make uninstall
```

> **Note**: Docker build for Claude Code installer requires 4GiB or more memory. Use `colima start --memory 4` instead of plain `colima start`.

### DevContainer Operations

To rebuild the container after changing `.devcontainer/Dockerfile`:
- Use Command Palette: `Dev Containers: Rebuild Container`

## Environment Setup Notes

**macOS Users Without Docker Desktop**: This project includes a `Makefile` with automation for setting up Colima as a Docker Desktop alternative. The `make install` command handles installation and configuration of Docker CLI, Colima, and the buildx plugin.

**Recommended VS Code Extension**: The DevContainer automatically suggests installing `Anthropic.claude-code` (.devcontainer/devcontainer.json).

**Colima Memory Requirement**: When using Colima, allocate at least 4GiB of memory (`colima start --memory 4`). The Claude Code installer consumes significant memory during Docker build, and 2GiB is insufficient.
