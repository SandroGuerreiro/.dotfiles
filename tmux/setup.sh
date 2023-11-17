#!/bin/bash

setup_name="Tmux"

# Create symbolic link
origin_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/.tmux.conf"
dest_path="$HOME/.tmux.conf"

if [ -f "$dest_path" ]; then
	read -p "There's an existing [$setup_name] config file in your environment, do you want to replace it? (y/n)" yn
	
	case $yn in
		[nN] ) 	echo "Aborting"
			exit;;
	esac

	rm "$dest_path"
fi

echo "Creating [$setup_name] symlink"
ln -s "$origin_path" "$dest_path"

#Install plugin manager
plugins_path="$HOME/.tmux/plugins"

if [ ! -d "$plugins_path" ]; then
	echo "Creating plugins directory"
	mkdir -p "$plugins_path"
fi

if [ ! -d "$plugins_path/tpm" ]; then
	echo "Cloning tpm plugin"
	git clone https://github.com/tmux-plugins/tpm "$plugins_path/tpm"
else
	echo "Updating tpm plugin"
	git -C "$plugins_path/tpm" pull
fi

tmux source "$dest_path"
echo "Installing plugins"
$plugins_path/tpm/scripts/install_plugins.sh
echo "[$setup_name] installed"
