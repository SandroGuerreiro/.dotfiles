#!/bin/bash

setup_name="Alacritty"

alacritty_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/.alacritty.yml"

if [ -f "$alacritty_path" ]; then
	read -p "There's an existing [$setup_name] config file in your environment, do you want to replace it? (y/n)" yn
	
	case $yn in
		[nN] ) 	echo "Aborting"
			exit;;
	esac

fi

ln -s "$alacritty_path" "$HOME/.alacritty.yml"

echo "[$setup_name] installed"
