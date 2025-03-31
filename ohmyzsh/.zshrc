# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Vault configuration
export VAULT_ADDR=""
export VAULT_AUTH_METHOD=github
export VAULT_AUTH_TOKEN=""

DISABLE_MAGIC_FUNCTIONS=true

# Mysql
export LDFLAGS="-L/opt/homebrew/opt/mysql-client/lib"
export CPPFLAGS="-I/opt/homebrew/opt/mysql-client/include"

# Path configuration
export PATH="$HOME/.local/bin":$PATH

# Nvm configuration
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh

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
# ZSH_THEME="robbyrussell" # OhMyZshTheme
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

# User configuration
# export MANPATH="/usr/local/man:$MANPATH"
# export LANG=en_US.UTF-8 # You may need to manually set your language environment

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


# pnpm
export PNPM_HOME="/Users/sandroguerreiro/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Enable path autocompletion for 'code' alias
_code_autocomplete() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $(compgen -d ~/Code/$cur) )
}
complete -o nospace -F _code_autocomplete code
