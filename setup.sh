alacritty_setup="alacritty/setup.sh"
chmod +x "$alacritty_setup"
$alacritty_setup

git_setup="./git/setup.sh"
chmod +x "$git_setup"
$git_setup

nvim_setup="./nvim/setup.sh"
chmod +x "$nvim_setup"
$nvim_setup

tmux_setup="./tmux/setup.sh"
chmod +x "$tmux_setup"
$tmux_setup
