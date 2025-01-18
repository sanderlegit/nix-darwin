{ pkgs, ...}:

#####################################
#
# zsh configuration
#
#####################################

{
  programs.zsh = {
    # ohMyZsh = {
    #   enable = true;
    #   plugins = [ "git" "sudo" "docker" "kubectl" ];
    # };
    enable = true;
    interactiveShellInit = ''
# First, ensure completion system is initialized
autoload -Uz compinit
compinit

# Enable additional zsh settings that fzf-tab depends on
zstyle ':completion:*' menu select
zmodload zsh/complist

# Source fzf completion and keybindings first
if [[ -f ${pkgs.fzf}/share/fzf/completion.zsh ]]; then
source ${pkgs.fzf}/share/fzf/completion.zsh
fi
if [[ -f ${pkgs.fzf}/share/fzf/key-bindings.zsh ]]; then
source ${pkgs.fzf}/share/fzf/key-bindings.zsh
fi

# Then source fzf-tab
if [[ -f ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh ]]; then
source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
fi

# Configure fzf behavior
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
export FZF_CTRL_R_OPTS="--sort --exact"
export FZF_DEFAULT_COMMAND='rg --files'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

bindkey "ç" fzf-cd-widget

# Aliases
alias lg="lazygit"
alias ld="lazydocker"
# alias air='~/.air'

alias nosleep="sudo pmset -b disablesleep 1"
alias yessleep="sudo pmset -b disablesleep 0"

alias cu="cd .. && ll"
ci () {
cd $1 && ll
}

export EDITOR=hx

alias nre="darwin-rebuild switch --flake ~/nix#m4 --show-trace -v"
    '';
  };
}
