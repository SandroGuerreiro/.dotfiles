if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Vault configuration
export VAULT_ADDR=""
export VAULT_AUTH_METHOD=github
export VAULT_AUTH_TOKEN=""

DISABLE_MAGIC_FUNCTIONS=true

# OS detection
case "$(uname -s)" in
  Darwin) IS_MAC=1 ;;
  Linux)  IS_LINUX=1 ;;
esac

# Homebrew prefix (mac uses /opt/homebrew on Apple Silicon, /usr/local on Intel)
if [ -n "$IS_MAC" ]; then
  if [ -x /opt/homebrew/bin/brew ]; then
    BREW_PREFIX=/opt/homebrew
  elif [ -x /usr/local/bin/brew ]; then
    BREW_PREFIX=/usr/local
  fi
fi

# Mysql client (mac/homebrew)
if [ -n "$IS_MAC" ] && [ -d "$BREW_PREFIX/opt/mysql-client" ]; then
  export LDFLAGS="-L$BREW_PREFIX/opt/mysql-client/lib"
  export CPPFLAGS="-I$BREW_PREFIX/opt/mysql-client/include"
fi

# Path configuration
export PATH="$HOME/.local/bin":$PATH

# Auto-cd: type a directory name to cd into it
setopt AUTO_CD
# cdpath: search ~/Code when a name doesn't match a local directory
cdpath=(~/Code)

# Nvm configuration — try common locations across platforms
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ -n "$IS_MAC" ] && [ -n "$BREW_PREFIX" ] && [ -s "$BREW_PREFIX/opt/nvm/nvm.sh" ]; then
  source "$BREW_PREFIX/opt/nvm/nvm.sh"
elif [ -s "$NVM_DIR/nvm.sh" ]; then
  source "$NVM_DIR/nvm.sh"
fi

# Editor
export EDITOR=nvim
export VISUAL=nvim
# Override `sudo nvim` / `sudo vim` to preserve your user config.
# Plain `sudo nvim` runs as root with no plugins (gives you netrw).
sudo() {
  if [[ "$1" == "nvim" || "$1" == "vim" ]]; then
    shift
    command sudo -E HOME="$HOME" \
      XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}" \
      XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}" \
      XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}" \
      XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}" \
      nvim "$@"
  else
    command sudo "$@"
  fi
}

# Git aliases
alias gs="git status"
alias gco="git checkout --track -b origin/"
alias gcm="git commit -m "

# Add 'code' alias for navigating to ~/Code with autocompletion
alias coding="cd ~/Code"

alias v2="cd ~/Code/recharge-v2"

# PNPM aliases
alias pnpmV2="corepack prepare pnpm@latest-8 --activate"
alias pnpmLat="corepack prepare pnpm@latest --activate"

# AWS aliases
alias aws-prd='aws-vault exec recharge-production -- aws'
alias aws-acc='aws-vault exec recharge-acceptance -- aws'
alias aws-dev='aws-vault exec recharge-development -- aws'

alias tf-prd='aws-vault exec recharge-production -- terraform'
alias tf-acc='aws-vault exec recharge-acceptance -- terraform'
alias tf-dev='aws-vault exec recharge-development -- terraform'

alias cdktf-prd='aws-vault exec recharge-production -- cdktf'
alias cdktf-acc='aws-vault exec recharge-acceptance -- cdktf'
alias cdktf-dev='aws-vault exec recharge-development -- cdktf'

alias nx-prd='export RECHARGE_ENVIRONMENT=production && aws-vault exec recharge-production -- nx'
alias nx-acc='export RECHARGE_ENVIRONMENT=acceptance && aws-vault exec recharge-acceptance -- nx'
alias nx-dev='export RECHARGE_ENVIRONMENT=development && aws-vault exec recharge-development -- nx'
alias nx-infradev='export RECHARGE_ENVIRONMENT=infradev && aws-vault exec recharge-development -- nx'
alias nx-prd-super='export RECHARGE_ENVIRONMENT=production && aws-vault exec recharge-production-superuser -- nx'
alias nx-acc-super='export RECHARGE_ENVIRONMENT=acceptance && aws-vault exec recharge-acceptance-superuser -- nx'
alias nx-dev-super='export RECHARGE_ENVIRONMENT=development && aws-vault exec recharge-development-superuser -- nx'
alias nx-infradev-super='export RECHARGE_ENVIRONMENT=infradev && aws-vault exec recharge-development-superuser -- nx'

alias k-prd='aws-vault exec recharge-production -- kubectl'
alias k-acc='aws-vault exec recharge-acceptance -- kubectl'
alias k-dev='aws-vault exec recharge-development -- kubectl'
alias k-prd-super='aws-vault exec recharge-production-superuser -- kubectl'
alias k-acc-super='aws-vault exec recharge-acceptance-superuser -- kubectl'
alias k-dev-super='aws-vault exec recharge-development-superuser -- kubectl'

alias prd='aws-vault exec recharge-production --'
alias acc='aws-vault exec recharge-acceptance --'
alias dev='aws-vault exec recharge-development --'
alias prd-super='aws-vault exec recharge-production-super --'
alias acc-super='aws-vault exec recharge-acceptance-super --'
alias dev-super='aws-vault exec recharge-development-super --'


# Oh My ZSH configuration
export ZSH="$HOME/.oh-my-zsh" # Path to the file
ZSH_THEME="powerlevel10k/powerlevel10k" # OhMyZshTheme

# Load secrets from secrets file
if [ -f ~/.zshrc_secrets ]; then
    source ~/.zshrc_secrets
fi

# ====================== PLUGINS =========================
plugins=(
  git
  zsh-history-substring-search
  zsh-autosuggestions
  F-Sy-H
)
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

source $ZSH/oh-my-zsh.sh

# pnpm
if [ -n "$IS_MAC" ]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Enable path autocompletion for 'code' command
_code_autocomplete() {
  _directories -W ~/Code
}
compdef _code_autocomplete code
