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

# Get plugins
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/z-shell/F-Sy-H.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/F-Sy-H
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions


if [ -d "$ohmyzsh_directory" ]; then
	omz update
else
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ln -s "$ohmyzsh_path" "$dest_path"
touch "$secrets_path" 

echo "[$setup_name] installed"
