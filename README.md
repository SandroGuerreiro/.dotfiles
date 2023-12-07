# .dotfiles config

This repository is used to setup my entire dotfiles config.

## Installation

To install these .dotfiles you will need only need to run the setup.sh file, however there are a few requirements before it can be run.

### Requirements

- alacritty
- git
- tmux
- nvim

**In case you want to skip any of these configs you can delete the lines in the [setup file](.dotfiles/setup.sh)**

After that, all you need to do is run setup.sh in the base directory.
```bash
./setup.sh
```
You will probably need to give permissions on the main setup.sh file. You can do that by:
```bash
chmod +x ./setup.sh
```

### zsh vars

Zsh vars will not contain any secrets, these secrets will be contained in a separate file that is not included in this project. After you run the setup, you will find in your home path, the file .zshrc_secrets where you can insert all vars you desire
