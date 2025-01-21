{ pkgs, ...}:

#####################################
#
# zsh configuration
#
#####################################

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # initExtra = ''
    #   export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    # '';
    # oh-my-zsh = {
    #   enable = true;
    #   theme = "robbyrussell";
    #   plugins = [
    #     "sudo"
    #     "terraform"
    #     "systemadmin"
    #     "vi-mode"
    #   ];
    # };
    # ohMyZsh = {
    #   enable = true;
    #   plugins = [ "git" "sudo" "docker" "kubectl" ];
    # };
#     enable = true;
    interactiveShellInit = ''
# First, ensure completion system is initialized
autoload -Uz compinit
compinit

# Enable additional zsh settings that fzf-tab depends on
zstyle ':completion:*' menu select
zmodload zsh/complist

## FZF
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

# MacOS Alt-C char
bindkey "ç" fzf-cd-widget

function fw() {
RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
INITIAL_QUERY="$*"
fzf --ansi --disabled --query "$INITIAL_QUERY" \
    --bind "start:reload:$RG_PREFIX {q}" \
    --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
    --delimiter : \
    --height '80%' \
    --preview 'bat --color=always {1} --highlight-line {2}' \
    --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
    --bind "enter:become($EDITOR {1}:{2}:{3})"
}

## git
function aug-env {
  export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519_auguria"
}


## Aliases
alias l="ls -la"
alias ll="ls -la"
alias lg="lazygit"
alias ld="lazydocker"
# alias air='~/.air'

alias cu="cd .. && ll"
ci () {
cd $1 && ll
}

export EDITOR=hx

## macos system
alias nosleep="sudo pmset -b disablesleep 1"
alias yessleep="sudo pmset -b disablesleep 0"

## nix 

alias nre="darwin-rebuild switch --flake ~/nix#m4 --show-trace -v"

## python
function poetry-venv {
  TARGET_DIR=$1
  if [ "$#" -ne 1 ]; then
    TARGET_DIR="."
  fi

  ORIGINAL_DIR=$(pwd)

  if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' does not exist"
    return 1
  fi

  if [ ! -d "$TARGET_DIR/venv" ]; then
    echo "Error: No venv found in '$TARGET_DIR'"
    return 1
  fi

  cd "$TARGET_DIR"
  source ./venv/bin/activate
  poetry env info
  cd "$ORIGINAL_DIR"
}

function poetry-venv-re {
  if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: poetry-venv-re PYTHON_VERSION [--no-root]"
    echo "Example: poetry-venv-re python3.11 --no-root"
    return 1
  fi

  PYTHON_VERSION=$1
  
  # Validate python version arg
  if ! command -v "$PYTHON_VERSION" >/dev/null 2>&1; then
    echo "Error: Python version '$PYTHON_VERSION' not found"
    return 1
  fi

  # Validate --no-root flag if provided
  if [ "$#" -eq 2 ] && [ "$2" != "--no-root" ]; then
    echo "Error: Second argument must be '--no-root' if provided"
    return 1
  fi

  rm -rf venv
  $PYTHON_VERSION -m venv "venv"
  source ./venv/bin/activate
  poetry env info
  poetry install $2  # Will be either empty or "--no-root"
}

## docker
# when installed with advanced/instsall-in-home-dir
# putting it first so it doesnt conflict
# https://docs.docker.com/desktop/setup/install/mac-install/
export PATH=$HOME/.docker/bin:$PATH
  '';
  };
}
