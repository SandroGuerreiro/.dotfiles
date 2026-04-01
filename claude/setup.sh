#!/bin/bash

setup_name="Claude"
base_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
dest_path="$HOME/.claude"

# Ensure ~/.claude exists (Claude creates it on first run, but just in case)
mkdir -p "$dest_path"

# Portable config: these directories and files get symlinked
dirs=(agents commands rules scripts)
files=(settings.json)

# Symlink directories
for dir in "${dirs[@]}"; do
	origin="$base_path/$dir"
	target="$dest_path/$dir"

	if [ -e "$target" ] && [ ! -L "$target" ]; then
		read -p "There's an existing [$setup_name/$dir] config in your environment, do you want to replace it? (y/n) " yn
		case $yn in
			[nN] )	echo "Skipping $dir"
				continue;;
		esac
		rm -rf "$target"
	elif [ -L "$target" ]; then
		rm "$target"
	fi

	echo "Creating [$setup_name/$dir] symlink"
	ln -s "$origin" "$target"
done

# Symlink files
for file in "${files[@]}"; do
	origin="$base_path/$file"
	target="$dest_path/$file"

	if [ -e "$target" ] && [ ! -L "$target" ]; then
		read -p "There's an existing [$setup_name/$file] config in your environment, do you want to replace it? (y/n) " yn
		case $yn in
			[nN] )	echo "Skipping $file"
				continue;;
		esac
		rm "$target"
	elif [ -L "$target" ]; then
		rm "$target"
	fi

	echo "Creating [$setup_name/$file] symlink"
	ln -s "$origin" "$target"
done

echo "[$setup_name] installed"
