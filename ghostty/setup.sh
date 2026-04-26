#!/bin/bash

setup_name="Ghostty"

origin_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/config"
dest_dir="$HOME/.config/ghostty"
dest_path="$dest_dir/config"

install_font_mac() {
	# Geist Mono Nerd Font via Homebrew cask
	if command -v brew &>/dev/null; then
		if brew list --cask font-geist-mono-nerd-font &>/dev/null; then
			echo "[$setup_name] font already installed (brew cask)"
		else
			echo "[$setup_name] installing font: font-geist-mono-nerd-font"
			brew install --cask font-geist-mono-nerd-font
		fi
	else
		echo "[$setup_name] warning: brew not found, skipping font install"
	fi
}

install_font_linux() {
	# Geist Mono Nerd Font is not in distro repos — fetch from Nerd Fonts release
	local font_dir="$HOME/.local/share/fonts/GeistMonoNerdFont"
	if [ -d "$font_dir" ] && [ -n "$(ls -A "$font_dir" 2>/dev/null)" ]; then
		echo "[$setup_name] font already installed at $font_dir"
		return
	fi

	if ! command -v curl &>/dev/null || ! command -v unzip &>/dev/null; then
		echo "[$setup_name] warning: curl/unzip required for font install, skipping"
		return
	fi

	echo "[$setup_name] downloading Geist Mono Nerd Font..."
	mkdir -p "$font_dir"
	local tmp
	tmp=$(mktemp -d)
	if curl -fsSL -o "$tmp/font.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/GeistMono.zip; then
		unzip -qo "$tmp/font.zip" -d "$font_dir"
		if command -v fc-cache &>/dev/null; then
			fc-cache -f "$font_dir" >/dev/null 2>&1
		fi
		echo "[$setup_name] font installed at $font_dir"
	else
		echo "[$setup_name] warning: font download failed, skipping"
	fi
	rm -rf "$tmp"
}

case "$(uname -s)" in
	Darwin) install_font_mac ;;
	Linux)  install_font_linux ;;
	*)      echo "[$setup_name] warning: unknown OS, skipping font install" ;;
esac

if [ -e "$dest_path" ]; then
	read -p "There's an existing [$setup_name] config in your environment, do you want to replace it? (y/n)" yn

	case $yn in
		[nN] ) 	echo "Aborting"
			exit;;
	esac

	rm "$dest_path"
fi

mkdir -p "$dest_dir"
ln -s "$origin_path" "$dest_path"

echo "[$setup_name] installed"
