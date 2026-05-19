ZSH_CONFIG_DIR=$HOME/.config/zsh

source $ZSH_CONFIG_DIR/utils.zsh
source_if_exists $ZSH_CONFIG_DIR/path.zsh
source_if_exists $ZSH_CONFIG_DIR/antidote.zsh
source_if_exists $ZSH_CONFIG_DIR/completions.zsh
source_if_exists $ZSH_CONFIG_DIR/configs.zsh
source_if_exists $ZSH_CONFIG_DIR/secrets.zsh
source_if_exists $ZSH_CONFIG_DIR/aliases.zsh
source_if_exists $ZSH_CONFIG_DIR/device.zsh
