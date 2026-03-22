# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a general-purpose VS Code DevContainer sample project for Node.js development with AI coding assistants. The project demonstrates how to set up a consistent development environment using DevContainers, allowing developers to use AI tools like Gemini CLI, Claude Code, and OpenAI Codex without polluting their local environment.

## DevContainer Architecture

The project uses a minimal Alpine Linux-based Node.js container:

- **Base Image**: `node:24-alpine` (.devcontainer/Dockerfile:1)
- **Remote User**: `node` (non-root user for security)
- **Workspace**: `/workspace` (mounted from project root)
- **Pre-installed Tools**: Claude Code (native install via Dockerfile), npm packages (`@google/gemini-cli`, `@openai/codex`)
- **VS Code Extensions**: `google.gemini-code-assist` and `Anthropic.claude-code`

The DevContainer setup installs dependencies at container startup time. When using VS Code DevContainers, the `postCreateCommand` in `devcontainer.json` runs `npm install`. When using `start-container.sh`, it automatically runs `npm install` before presenting the shell.

## Common Commands

### Using AI Coding Assistants

#### Gemini CLI

```bash
# Direct command
gemini --help

# Via npm script
npm run gemini -- --help
```

#### Claude Code

```bash
# Direct command
claude --help

# Via npm script
npm run claude -- --help
```

#### OpenAI Codex

```bash
# Direct command
codex --help

# Via npm script
npm run codex -- --help
```

### Container Management (macOS alternative to Docker Desktop)

```bash
# Initial setup (installs Docker, Colima, buildx plugin)
make install

# Start Colima (after initial setup)
colima start

# Stop Colima
colima stop

# Uninstall all components
make uninstall
```

### DevContainer Operations

To rebuild the container after changing `.devcontainer/Dockerfile` or `package.json`:
- Use Command Palette: `Dev Containers: Rebuild Container`

## Environment Setup Notes

**macOS Users Without Docker Desktop**: This project includes a `Makefile` with automation for setting up Colima as a Docker Desktop alternative. The `make install` command handles installation and configuration of Docker CLI, Colima, and the buildx plugin.

**Recommended VS Code Extensions**: The DevContainer automatically suggests installing AI coding assistants: `google.gemini-code-assist` and `Anthropic.claude-code` (.devcontainer/devcontainer.json:10-13).

## Modifying Dependencies

When adding new npm packages:
1. Update `package.json`
2. Restart the container or run `npm install` manually (packages are installed at container startup, not during build)
