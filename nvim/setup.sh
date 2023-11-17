#!/bin/bash

setup_name="NVim"

# Create symbolic link
origin_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
dest_path=$HOME/.config/nvim

if [ -d "$dest_path" ]; then
	read -p "There's an existing [$setup_name] config file in your environment, do you want to replace it? (y/n)" yn
	
	case $yn in
		[nN] ) 	echo "Aborting"
			exit;;
	esac

	rm -r "$dest_path"
fi

echo "Creating [$setup_name] directory"
mkdir $dest_path

excluded_files=(".DS_Store" "setup.sh")

cmd=""
for file in "${excluded_files[@]}"; do
	cmd+=" ! -name $file"
done

find "$origin_path" -type f $cmd | while read -r file; do
	echo "Symlinking file [$file]"
	rel_path="${file#$origin_path}"
	mkdir -p "$dest_path$( dirname "$rel_path")"
	ln -s "$file" "$dest_path$rel_path"
done

echo "[$setup_name] installed"
