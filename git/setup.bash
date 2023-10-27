#!/bin/bash

global_ignore_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/.gitignore_global"

ln -s "$global_ignore_path" "$HOME/.gitignore_global"

git config --global core.excludesfile ~/.gitignore_global
