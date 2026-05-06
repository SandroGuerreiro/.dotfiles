#!/bin/bash

setup_name="NVim"

# Create symbolic link
origin_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
dest_path=$HOME/.config/nvim

if [ -e "$dest_path" ]; then
	read -p "There's an existing [$setup_name] config in your environment, do you want to replace it? (y/n)" yn

	case $yn in
		[nN] ) 	echo "Aborting"
			exit;;
	esac

	rm -rf "$dest_path"
fi

echo "Creating [$setup_name] symlink"
ln -s "$origin_path" "$dest_path"

echo "[$setup_name] installed"

# ── LSP servers ──────────────────────────────────────────────────────────
echo "[$setup_name] Installing LSP servers..."

# lua-language-server and gopls via package manager
if command -v brew &>/dev/null; then
	brew install lua-language-server gopls 2>/dev/null || true
elif command -v apt-get &>/dev/null; then
	sudo apt-get install -y lua-language-server golang-go && go install golang.org/x/tools/gopls@latest 2>/dev/null || true
elif command -v dnf &>/dev/null; then
	sudo dnf install -y lua-language-server golang && go install golang.org/x/tools/gopls@latest 2>/dev/null || true
elif command -v pacman &>/dev/null; then
	sudo pacman -S --needed --noconfirm lua-language-server gopls 2>/dev/null || true
fi

# typescript LSP + eslint via npm (node is a prerequisite already ensured by root setup.sh)
if command -v npm &>/dev/null; then
	npm install -g typescript-language-server typescript vscode-langservers-extracted 2>/dev/null || true
else
	echo "[$setup_name] npm not found — skipping typescript-language-server and eslint"
fi

echo "[$setup_name] LSP servers installed"
