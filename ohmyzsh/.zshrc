# Vault configuration
export VAULT_ADDR=""
export VAULT_AUTH_METHOD=github
export VAULT_AUTH_TOKEN=""

# Path configuration
export PATH="$HOME/.local/bin":$PATH

# Nvim configuration
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh

# Oh My ZSH configuration
export ZSH="$HOME/.oh-my-zsh" # Path to the file
ZSH_THEME="robbyrussell" # OhMyZshTheme
# CASE_SENSITIVE="true" # Use case-sensitive completion
# HYPHEN_INSENSITIVE="true" # Hyphen-insensitive completion (CASE_SENSITIVE must off for this)
# zstyle ':omz:update' mode disabled  # Update rules: disabled | auto | reminder
# zstyle ':omz:update' frequency 13 # Frequency of updates in days
# DISABLE_MAGIC_FUNCTIONS="true" # If the links and text pasting is behaving weird
# DISABLE_LS_COLORS="true" # Uncomment the following line to disable colors in ls.
# DISABLE_AUTO_TITLE="true" # Disable auto-setting terminal title.
# ENABLE_CORRECTION="true" # Enable command auto-correction.
# COMPLETION_WAITING_DOTS="true" # Display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f" # Change displayed waiting message
# DISABLE_UNTRACKED_FILES_DIRTY="true" # Disable marking untracked files
# HIST_STAMPS="mm/dd/yyyy" # Change the command execution time: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# ZSH_CUSTOM=/path/to/new-custom-folder # Use another custom folder than $ZSH/custom

# Load secrets from secrets file
if [ -f ~/.zshrc_secrets ]; then
    source ~/.zshrc_secrets
fi

# ====================== PLUGINS =========================
# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
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

