#!/bin/bash

setup_name="OhMyZsh"

ohmyzsh_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/.zshrc"
ohmyzsh_directory="$HOME/.oh-my-zsh"
dest_path="$HOME/.zshrc"
secrets_path="$HOME/.zshrc_secrets"

if [ -f "$dest_path" ] || [ -L "$dest_path" ]; then
	read -p "There's an existing [.zshrc] config file in your environment, do you want to replace it? (y/n) " yn

	case $yn in
		[nN] ) 	echo "Aborting"
			exit;;
	esac

	rm "$dest_path"
fi

# Install oh-my-zsh first — its installer refuses to run if ~/.oh-my-zsh already exists,
# so plugins/themes must be cloned AFTER. RUNZSH=no avoids launching zsh at the end;
# CHSH=no skips the password prompt to change the default shell. Run `chsh -s $(which zsh)`
# yourself if you want zsh as the login shell.
if [ ! -d "$ohmyzsh_directory" ]; then
	echo "[$setup_name] installing oh-my-zsh"
	RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
	echo "[$setup_name] oh-my-zsh already installed, updating"
	if command -v omz &>/dev/null; then
		omz update --unattended || true
	fi
fi

# Plugin/theme directories. Skip if already cloned (idempotent re-runs).
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_if_missing() {
	local repo="$1" dest="$2"
	if [ ! -d "$dest" ]; then
		git clone --depth=1 "$repo" "$dest"
	fi
}

clone_if_missing https://github.com/romkatv/powerlevel10k.git              "$ZSH_CUSTOM/themes/powerlevel10k"
clone_if_missing https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
clone_if_missing https://github.com/zsh-users/zsh-autosuggestions          "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_if_missing https://github.com/z-shell/F-Sy-H.git                     "$ZSH_CUSTOM/plugins/F-Sy-H"
clone_if_missing https://github.com/zsh-users/zsh-completions              "$ZSH_CUSTOM/plugins/zsh-completions"

# omz install creates its own ~/.zshrc — overwrite with our symlink.
[ -f "$dest_path" ] && rm "$dest_path"
ln -s "$ohmyzsh_path" "$dest_path"
touch "$secrets_path"

echo "[$setup_name] installed"
