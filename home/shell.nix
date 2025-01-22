{pkgs, ...}: {
  programs.ripgrep.enable = true;

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "rg --files";
    defaultOptions = ["--height 40%" "--layout=reverse" "--border"];
    fileWidgetCommand = "rg --files";
    historyWidgetOptions = ["--sort" "--exact"];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;

    initExtra = ''
      # Path configurations
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin:$HOME/.docker/bin"
      export EDITOR=hx

      # Load completion system
      autoload -Uz compinit
      compinit

      # Enable menu selection in completion
      zstyle ':completion:*' menu select
      zmodload zsh/complist

      # 0 -- vanilla completion (abc => abc)
      # 1 -- smart case completion (abc => Abc)
      # 2 -- word flex completion (abc => A-big-Car)
      # 3 -- full flex completion (abc => ABraCadabra)
      zstyle ':completion:*' matcher-list ''' \
        'm:{a-z\-}={A-Z\_}' \
        'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
        'r:|?=** m:{a-z\-}={A-Z\_}'


      # FZF function for file search with preview
      function fw() {
        local RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
        local INITIAL_QUERY="$*"
        fzf --ansi --disabled --query "$INITIAL_QUERY" \
          --bind "start:reload:$RG_PREFIX {q}" \
          --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
          --delimiter : \
          --height '80%' \
          --preview 'bat --color=always {1} --highlight-line {2}' \
          --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
          --bind "enter:become($EDITOR {1}:{2}:{3})"
      }

      # Git SSH configuration
      function aug-env {
        export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519_auguria"
      }

      functions ci() {
        cd $1 && ll
      }

      # Python Poetry functions
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
        
        if ! command -v "$PYTHON_VERSION" >/dev/null 2>&1; then
          echo "Error: Python version '$PYTHON_VERSION' not found"
          return 1
        fi
        if [ "$#" -eq 2 ] && [ "$2" != "--no-root" ]; then
          echo "Error: Second argument must be '--no-root' if provided"
          return 1
        fi
        rm -rf venv
        $PYTHON_VERSION -m venv "venv"
        source ./venv/bin/activate
        poetry env info
        poetry install $2
      }

      # MacOS specific configurations
      bindkey "ç" fzf-cd-widget
    '';

    shellAliases = {
      k = "kubectl";
      l = "ls -la";
      ll = "ls -la";
      lg = "lazygit";
      ld = "lazydocker";
      cu = "cd .. && ll";
      nosleep = "sudo pmset -b disablesleep 1";
      yessleep = "sudo pmset -b disablesleep 0";
      nre = "darwin-rebuild switch --flake ~/nix#m4 --show-trace -v";
    };

  };
}
