#!/bin/bash

setup_name="Ghostty"

origin_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/config"
dest_dir="$HOME/.config/ghostty"
dest_path="$dest_dir/config"

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
