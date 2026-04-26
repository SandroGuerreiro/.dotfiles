# .dotfiles config

This repository is used to setup my entire dotfiles config. Cross-platform: macOS and Linux.

## Installation

```bash
chmod +x ./setup.sh
./setup.sh
```

`setup.sh` will:

1. Detect your package manager (brew / dnf / apt / pacman) and install any missing required tools (zsh, tmux, neovim, nodejs, curl, unzip) plus optional GUI tools (alacritty, ghostty) if they're available in your repos.
2. Run each component's individual setup script to symlink configs, install plugins, and fetch fonts.

On Linux you'll be prompted for `sudo` once for the package install. On macOS, `brew` does not require sudo.

If your distro doesn't ship one of the optional GUI tools (e.g. ghostty on Debian/Ubuntu), install it manually — see the project's homepage.

**To skip a component**, comment out its line near the bottom of [`setup.sh`](./setup.sh).

### zsh vars

Zsh vars do not contain any secrets. Secrets live in `~/.zshrc_secrets`, which is created (empty) by the ohmyzsh setup. Add your private exports there — it's never committed.

### Claude Code settings

`claude/settings.json.tmpl` is rendered into `~/.claude/settings.json` by `claude/setup.sh` (the `__HOME__` placeholder is substituted with the actual `$HOME`). **Edit the template, not the generated file.**

The default template references hooks that live in a sibling repo (`~/Code/everything-claude-code`). If you don't have it cloned, those hooks will fail at runtime — clone the repo or remove the relevant hook entries from the template.

`additionalDirectories` points at `~/Code/Astrolabe` — remove if you don't have that repo locally.
