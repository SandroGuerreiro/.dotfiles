#!/bin/bash

origin_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
dest_path=$HOME/.config/nvim

# Check if nvim directory exists
if [ ! -d "$dest_path" ]; then
	echo "Creating directory"
	mkdir $dest_path
fi

find "$origin_path" -type f ! -name .DS_Store ! -name setup.bash | while read -r file; do
	rel_path="${file#$origin_path}"
	mkdir -p "$dest_path$( dirname "$rel_path")"
	ln -s "$file" "$dest_path$rel_path"
done
