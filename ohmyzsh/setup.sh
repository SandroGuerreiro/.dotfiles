#!/bin/bash

setup_name="OhMyZsh"

ohmyzsh_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/.zshrc"
ohmyzsh_directory="$HOME/.oh-my-zsh"
dest_path="$HOME/.zshrc"
secrets_path="$HOME/.zshrc_secrets"

if [ -f "$dest_path" ]; then
	read -p "There's an existing [.zsh] config file in your environment, do you want to replace it? (y/n)" yn
	
	case $yn in
		[nN] ) 	echo "Aborting"
			exit;;
	esac

	rm "$dest_path"

fi

if [ -d "$ohmyzsh_directory" ]; then
	omz update
else
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ln -s "$ohmyzsh_path" "$dest_path"
touch "$secrets_path" 

echo "[$setup_name] installed"
