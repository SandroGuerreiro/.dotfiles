#!/bin/bash

setup_name="Tooling"
echo "[$setup_name] Installing LSP servers and dev tools..."

# ESLint + HTML/CSS/JSON/Markdown language servers
if ! command -v vscode-eslint-language-server &>/dev/null; then
  echo "  → installing vscode-langservers-extracted (eslint, html, css, json)"
  npm install -g vscode-langservers-extracted
else
  echo "  ✓ vscode-langservers-extracted already installed"
fi

# TypeScript language server
if ! command -v typescript-language-server &>/dev/null; then
  echo "  → installing typescript-language-server"
  npm install -g typescript-language-server typescript
else
  echo "  ✓ typescript-language-server already installed"
fi

# Lua language server (brew)
if ! command -v lua-language-server &>/dev/null; then
  echo "  → installing lua-language-server"
  brew install lua-language-server
else
  echo "  ✓ lua-language-server already installed"
fi

echo "[$setup_name] done"
