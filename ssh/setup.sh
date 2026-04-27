#!/bin/bash

setup_name="SSH"
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

mkdir -p ~/.ssh
chmod 700 ~/.ssh

# SSH config
dest_config="$HOME/.ssh/config"
if [ -f "$dest_config" ]; then
	read -p "There's an existing [$setup_name] config file in your environment, do you want to replace it? (y/n)" yn
	case $yn in
		[nN] ) echo "Aborting"; exit ;;
	esac
	rm "$dest_config"
fi
ln -s "$script_dir/ssh_config" "$dest_config"
chmod 600 "$dest_config"

echo "[$setup_name] installed"
