#!/bin/bash

set -e

base_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/"

# ────────────────────────────────────────────────────────────────────────
# Prerequisite installation
# ────────────────────────────────────────────────────────────────────────
# Tools the rest of setup needs. Each component's setup.sh runs the actual
# config wiring; this section only ensures the binaries exist.

# Detect package manager
if command -v brew &>/dev/null; then
	PM=brew
elif command -v dnf &>/dev/null; then
	PM=dnf
elif command -v apt-get &>/dev/null; then
	PM=apt
elif command -v pacman &>/dev/null; then
	PM=pacman
else
	PM=none
fi

# Per-PM package names. Adjust here if a distro names something differently.
declare -A pkg_brew=( [zsh]=zsh [tmux]=tmux [nvim]=neovim [node]=node [curl]=curl [unzip]=unzip )
declare -A pkg_dnf=( [zsh]=zsh [tmux]=tmux [nvim]=neovim [node]=nodejs [curl]=curl [unzip]=unzip )
declare -A pkg_apt=( [zsh]=zsh [tmux]=tmux [nvim]=neovim [node]=nodejs [curl]=curl [unzip]=unzip )
declare -A pkg_pacman=( [zsh]=zsh [tmux]=tmux [nvim]=neovim [node]=nodejs [curl]=curl [unzip]=unzip )

# Required tools (binary-name keyed). git is implied — you needed it to clone.
required_keys=(zsh tmux nvim node curl unzip)
# Optional GUI tools — install if available in repos, skip silently otherwise.
optional_keys=(alacritty ghostty)

# Build install list of missing tools
to_install=()
for key in "${required_keys[@]}" "${optional_keys[@]}"; do
	# Map key → binary name to check (most match the key)
	bin="$key"
	[ "$key" = "node" ] && bin="node"
	if ! command -v "$bin" &>/dev/null; then
		to_install+=("$key")
	fi
done

resolve_pkg() {
	local key="$1"
	case "$PM" in
		brew)   echo "${pkg_brew[$key]:-$key}" ;;
		dnf)    echo "${pkg_dnf[$key]:-$key}" ;;
		apt)    echo "${pkg_apt[$key]:-$key}" ;;
		pacman) echo "${pkg_pacman[$key]:-$key}" ;;
		*)      echo "$key" ;;
	esac
}

if [ "${#to_install[@]}" -gt 0 ]; then
	echo "[bootstrap] Missing tools: ${to_install[*]}"

	if [ "$PM" = "none" ]; then
		echo "[bootstrap] No supported package manager found. Install these manually then re-run:"
		for key in "${to_install[@]}"; do echo "  - $key"; done
		exit 1
	fi

	pkgs=()
	for key in "${to_install[@]}"; do
		pkgs+=("$(resolve_pkg "$key")")
	done

	echo "[bootstrap] Installing via $PM: ${pkgs[*]}"
	case "$PM" in
		brew)   brew install "${pkgs[@]}" || true ;;
		dnf)    sudo dnf install -y "${pkgs[@]}" || true ;;
		apt)    sudo apt-get update && sudo apt-get install -y "${pkgs[@]}" || true ;;
		pacman) sudo pacman -S --needed --noconfirm "${pkgs[@]}" || true ;;
	esac
else
	echo "[bootstrap] All required tools present"
fi

# ────────────────────────────────────────────────────────────────────────
# Component selection
# ────────────────────────────────────────────────────────────────────────

all_components=(ssh alacritty git ohmyzsh nvim tmux ghostty claude tooling)
[ "$(uname)" = "Linux" ] && all_components+=(linux)
to_run=()

echo ""
echo "Select components to install (Enter = yes):"
echo ""
for comp in "${all_components[@]}"; do
	read -p "  $(printf '%-12s' "$comp") [Y/n] " yn
	case "${yn:-y}" in
		[nN]) ;;
		*) to_run+=("$comp") ;;
	esac
done
echo ""

# ────────────────────────────────────────────────────────────────────────
# Component setup
# ────────────────────────────────────────────────────────────────────────

run_setup() {
	local script="$1"
	chmod +x "$script"
	"$script"
}

for comp in "${to_run[@]}"; do
	run_setup "${base_path}${comp}/setup.sh"
done
