#!/bin/bash

setup_name="Linux"
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
user="$(whoami)"

# Sudo NOPASSWD
dest="/etc/sudoers.d/$user-nopasswd"
if [ -f "$dest" ]; then
	echo "[$setup_name] sudo already configured, skipping"
else
	echo "$user ALL=(ALL) NOPASSWD: ALL" | sudo tee "$dest" > /dev/null
	sudo chmod 440 "$dest"
	echo "[$setup_name] sudo configured"
fi

# KDE Plasma: ksshaskpass autostart for SSH key
if command -v ksshaskpass &>/dev/null; then
	mkdir -p ~/.config/autostart
	cp "$script_dir/ssh-add.desktop" ~/.config/autostart/ssh-add.desktop
	echo "[$setup_name] KDE SSH autostart configured"
fi

echo "[$setup_name] installed"
