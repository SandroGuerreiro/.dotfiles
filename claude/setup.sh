#!/bin/bash

setup_name="Claude"
base_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
dest_path="$HOME/.claude"

# Ensure ~/.claude exists (Claude creates it on first run, but just in case)
mkdir -p "$dest_path"

# Portable config: these directories get symlinked
dirs=(agents commands rules scripts)

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

# Render settings.json from template (substitutes $HOME so it works on any machine).
# Generated file, not symlinked — edit the .tmpl in this repo, not ~/.claude/settings.json.
template="$base_path/settings.json.tmpl"
target="$dest_path/settings.json"

if [ -e "$target" ] && [ ! -L "$target" ]; then
	read -p "There's an existing [$setup_name/settings.json] in your environment, do you want to replace it? (y/n) " yn
	case $yn in
		[nN] )	echo "Skipping settings.json" ;;
		*)	rm -f "$target"
			echo "Rendering [$setup_name/settings.json] from template"
			sed "s|__HOME__|$HOME|g" "$template" > "$target" ;;
	esac
else
	[ -L "$target" ] && rm "$target"
	echo "Rendering [$setup_name/settings.json] from template"
	sed "s|__HOME__|$HOME|g" "$template" > "$target"
fi

echo "[$setup_name] installed"
