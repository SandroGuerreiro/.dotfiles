#!/bin/bash

alacritty_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/.alacritty.yml"

ln -s "$alacritty_path" "$HOME/.alacritty.yml"
