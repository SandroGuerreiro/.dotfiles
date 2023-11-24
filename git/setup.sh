#!/bin/bash

setup_name="Git"

global_ignore_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/.gitignore_global"
dest_path="$HOME/.gitignore_global"

if [ -f "$dest_path" ]; then
	read -p "There's an existing [$setup_name] config file in your environment, do you want to replace it? (y/n)" yn
	
	case $yn in
		[nN] ) 	echo "Aborting"
			exit;;
	esac

	rm "$dest_path"
fi

ln -s "$global_ignore_path" "$dest_path"

git config --global core.excludesfile ~/.gitignore_global
echo "[$setup_name] installed"
