#!/bin/bash

base_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/"

alacritty_setup="${base_path}alacritty/setup.sh"
chmod +x "$alacritty_setup"
$alacritty_setup

git_setup="${base_path}./git/setup.sh"
chmod +x "$git_setup"
$git_setup

ohmyzsh_setup="${base_path}ohmyzsh/setup.sh"
chmod +x "$ohmyzsh_setup"
$ohmyzsh_setup

nvim_setup="${base_path}./nvim/setup.sh"
chmod +x "$nvim_setup"
$nvim_setup

tmux_setup="${base_path}./tmux/setup.sh"
chmod +x "$tmux_setup"
$tmux_setup

ghostty_setup="${base_path}ghostty/setup.sh"
chmod +x "$ghostty_setup"
$ghostty_setup

claude_setup="${base_path}claude/setup.sh"
chmod +x "$claude_setup"
$claude_setup

tooling_setup="${base_path}tooling/setup.sh"
chmod +x "$tooling_setup"
$tooling_setup
