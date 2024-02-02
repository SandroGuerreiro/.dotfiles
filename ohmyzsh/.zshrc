# Vault configuration
export VAULT_ADDR=""
export VAULT_AUTH_METHOD=github
export VAULT_AUTH_TOKEN=""

# Path configuration
export PATH="$HOME/.local/bin":$PATH

# Nvim configuration
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh

# Git aliases
alias gs="git status"
alias gco="git checkout --track -b origin/"

# Oh My ZSH configuration
export ZSH="$HOME/.oh-my-zsh" # Path to the file
ZSH_THEME="robbyrussell" # OhMyZshTheme

# Load secrets from secrets file
if [ -f ~/.zshrc_secrets ]; then
    source ~/.zshrc_secrets
fi

# ====================== PLUGINS =========================
plugins=(git)

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

