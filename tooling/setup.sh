#!/bin/bash

setup_name="Tooling"
echo "[$setup_name] Installing LSP servers and dev tools..."

# Detect OS / package manager
case "$(uname -s)" in
  Darwin) OS=mac ;;
  Linux)  OS=linux ;;
  *)      OS=unknown ;;
esac

if command -v brew &>/dev/null; then
  PM=brew
elif command -v dnf &>/dev/null; then
  PM=dnf
elif command -v apt-get &>/dev/null; then
  PM=apt
elif command -v pacman &>/dev/null; then
  PM=pacman
else
  PM=none
fi

# Configure npm to install global packages into ~/.local (Linux-friendly).
# On macOS with Homebrew this isn't needed (brew's prefix is user-writable),
# but doing it everywhere keeps installs consistent across machines.
# ~/.local/bin is added to PATH in .zshrc.
if [ "$OS" = "linux" ] && command -v npm &>/dev/null; then
  current_prefix=$(npm config get prefix 2>/dev/null)
  if [ "$current_prefix" = "/usr" ] || [ "$current_prefix" = "/usr/local" ] || [ -z "$current_prefix" ]; then
    echo "  → configuring npm prefix → \$HOME/.local"
    npm config set prefix "$HOME/.local"
    mkdir -p "$HOME/.local/bin" "$HOME/.local/lib/node_modules"
  fi
  export PATH="$HOME/.local/bin:$PATH"
fi

# ESLint + HTML/CSS/JSON/Markdown language servers
if ! command -v vscode-eslint-language-server &>/dev/null; then
  if command -v npm &>/dev/null; then
    echo "  → installing vscode-langservers-extracted (eslint, html, css, json)"
    npm install -g vscode-langservers-extracted
  else
    echo "  ⚠ npm not found, skipping vscode-langservers-extracted"
  fi
else
  echo "  ✓ vscode-langservers-extracted already installed"
fi

# TypeScript language server
if ! command -v typescript-language-server &>/dev/null; then
  if command -v npm &>/dev/null; then
    echo "  → installing typescript-language-server"
    npm install -g typescript-language-server typescript
  else
    echo "  ⚠ npm not found, skipping typescript-language-server"
  fi
else
  echo "  ✓ typescript-language-server already installed"
fi

# Lua language server
if ! command -v lua-language-server &>/dev/null; then
  echo "  → installing lua-language-server (via $PM)"
  case "$PM" in
    brew)   brew install lua-language-server ;;
    dnf)    sudo dnf install -y lua-language-server ;;
    apt)    sudo apt-get update && sudo apt-get install -y lua-language-server ;;
    pacman) sudo pacman -S --needed --noconfirm lua-language-server ;;
    none)   echo "  ⚠ no supported package manager found, install lua-language-server manually" ;;
  esac
else
  echo "  ✓ lua-language-server already installed"
fi

# Fedora's lua-language-server package installs the binary in /usr/libexec
# (not on PATH). Symlink into ~/.local/bin so nvim/lspconfig can find it.
if ! command -v lua-language-server &>/dev/null && [ -x /usr/libexec/lua-language-server/lua-language-server ]; then
  echo "  → symlinking lua-language-server into ~/.local/bin"
  mkdir -p "$HOME/.local/bin"
  ln -sf /usr/libexec/lua-language-server/lua-language-server "$HOME/.local/bin/lua-language-server"
fi

echo "[$setup_name] done"
