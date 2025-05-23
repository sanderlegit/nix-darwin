{ pkgs, ... }: {
  programs.ripgrep.enable = true;

  programs.fzf = {
    enable = true;
    enableZshIntegration = false; # configured manually
  };

  programs.skim = {
    enable = true;
    enableZshIntegration = false; # prevent skim trying to integrate with zsh
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;

    # Ensure bash completion support is loaded before completionInit runs
    initExtraBeforeCompInit = ''
      autoload -Uz +X compinit && compinit
      autoload -Uz bashcompinit && bashcompinit
    '';

    plugins = [
      { name = "fzf-tab"; src = pkgs.zsh-fzf-tab; }
      { name = "zsh-syntax-highlighting"; src = pkgs.zsh-syntax-highlighting; }
    ];

    # Add specific completion commands *after* the main completion system is initialized
    completionInit = ''
      # AWS CLI v2 completion using the Nix package path
      # Using pkgs.lib.getExe is slightly more robust than hardcoding /bin/
      local aws_completer_path="/run/current-system/sw/bin/aws_completer"
      if [[ -x "$aws_completer_path" ]]; then
        complete -C "$aws_completer_path" aws
      fi

      ## FZF
      # Source fzf completion and keybindings first
      if [[ -f ${pkgs.fzf}/share/fzf/key-bindings.zsh ]]; then
        source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      fi

      if [[ -f ${pkgs.fzf}/share/fzf/completion.zsh ]]; then
        source ${pkgs.fzf}/share/fzf/completion.zsh
      fi

      # # Ensure config is loaded properly
      # source <(fzf --zsh)

      # Configure fzf behavior
      export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --style minimal"
      export FZF_CTRL_R_OPTS="--sort --exact"
      export FZF_DEFAULT_COMMAND='rg --files'
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

      # Bind Ctrl+R to fuzzy history search
      bindkey '^R' fzf-history-widget
      # bindkey '^R' fzf-history-widget

      # Bind Ctrl+T to fuzzy file search
      bindkey '^T' fzf-file-widget
      # bindkey '^T' fzf-file-widget

      # Keep your existing binding for ç (Alt+C is another common cd binding: '\ec')
      # MacOS Alt-C char
      bindkey "ç" fzf-cd-widget

      zstyle ':completion:*' menu select
      zmodload zsh/complist
      # zstyle ':completion:*' matcher-list ''' \
      #  'm:{a-z\-}={A-Z\_}' \
      #  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
      #  'r:|?=** m:{a-z\-}={A-Z\_}'

      __aws_sso_profile_complete() {
           local _args=''${AWS_SSO_HELPER_ARGS:- -L error}
          _multi_parts : "($(/nix/store/s5s6si3kmz8k15vm9v6d5qk3mpa546cc-aws-sso-cli-1.17.0/bin/.aws-sso-wrapped ''${=_args} list --csv Profile))"
      }

      compdef __aws_sso_profile_complete aws-sso-profile
      complete -C /nix/store/s5s6si3kmz8k15vm9v6d5qk3mpa546cc-aws-sso-cli-1.17.0/bin/.aws-sso-wrapped aws-sso

    '';

    initExtra = ''

      export XDG_CONFIG_HOME=~/.config/

      # Path configurations
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin:$HOME/.docker/bin"

      # # Load completion system
      # autoload -Uz compinit
      # compinit

      # # Enable menu selection in completion
      # zstyle ':completion:*' menu select
      # zmodload zsh/complist

      # 0 -- vanilla completion (abc => abc)
      # 1 -- smart case completion (abc => Abc)
      # 2 -- word flex completion (abc => A-big-Car)
      # 3 -- full flex completion (abc => ABraCadabra)
      # zstyle ':completion:*' matcher-list ''' \
      #   'm:{a-z\-}={A-Z\_}' \
      #   'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
      #   'r:|?=** m:{a-z\-}={A-Z\_}'


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

      ##  zellix
 
      export ZELLIX_MOD="$HOME/dotfiles/zellix"

      function te() {
        # zellij ac rename-tab "hx $(basename "$(pwd)")"
        nu $ZELLIX_MOD/run.nu $ZELLIX_MOD/example $@
      }

      function pop {
        zellij ac rename-tab "$(basename "$(pwd)")"
        zellij run -f -x 0 -y 0 --width 100% --height 100% -- nu $ZELLIX_MOD/run.nu $ZELLIX_MOD/example
        # zellij run -f -x 0 -y 0 --width 100% --height 100% -- hx
      }

      export EDITOR=hx
      export PREVIEW_SH=$HOME/dotfiles/preview.sh

      function fw() {
        te $(sk --ansi --cmd "rg --column --line-number --no-heading --color=always --smart-case --hidden ." --delimiter ":" --height "100%" --preview "bat --color=always {1} --highlight-line {2}" --preview-window "up:60%:border")
      }

      function k9s() {
        context=$(kubectl config current-context | cut -c 1-10);
        # zellij ac rename-tab "k9s $context";
        command k9s
      }

      function lg() {
          # zellij ac rename-tab "lg"
          command lazygit
      }

      function gitui() {
          # zellij ac rename-tab "gitui"
          command gitui
      }

      function ld() {
          # zellij ac rename-tab "ld"
          command lazydocker
      }


      function zshconf() {
          cd ~/
          zellij ac rename-tab "zshconf"
          te ~/.zshrc
          source ~/.zshrc
          cd -
      }

      function drc() {
        zellij ac rename-tab "dotfiles"
        cd ~/dotfiles/ && nu $ZELLIX_MOD/run.nu $ZELLIX_MOD/example
        # cd ~/dotfiles/ && hx
        cd -
      }

      ## nix 

      function nre() {
        darwin-rebuild switch --flake ~/nix#m4 --show-trace -v
      }

      function nrc() {
        zellij ac rename-tab "nix-config"
        cd $HOME/nix/
        # nu $ZELLIX_MOD/run.nu $ZELLIX_MOD/example \
        hx \
         $HOME/nix/home/shell.nix \
         $HOME/nix/flake.nix && \
         darwin-rebuild switch --flake ~/nix#m4 --show-trace -v
        cd -
      }

      ## git
      function aug-env {
        export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519_auguria"
      }

      function u6-env {
        export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519_unit6"
      }

      # u6-env

      export VERTEXAI_PROJECT=gen-lang-client-0342800361
      export VERTEXAI_LOCATION=us-central1

      ## Aliases
      alias l="eza -la"
      alias ll="eza -la"
      alias ld="lazydocker"
      # alias ai="aider --no-attribute-author --no-attribute-committer --dark-mode"
      alias ai="uv run --no-project -p $HOME/.config/google-ai/.venv/bin/python aider --no-attribute-author --no-attribute-committer --dark-mode --model gemini-2.5-pro-preview-03-25"
      alias oi="aichat -m ollama:gemma3:27b"
      # alias air='~/.air'

      alias cu="cd .. && ll"
      ci () {
        cd $1 && ll
      }

      ## docker
      # when installed with advanced/instsall-in-home-dir
      # putting it first so it doesnt conflict
      # https://docs.docker.com/desktop/setup/install/mac-install/
      export PATH=$HOME/.docker/bin:$PATH

      export PATH=$HOME/.cargo/bin:$PATH

      ## AWS
      alias sam="sam --beta-features"

      # BEGIN_AWS_SSO_CLI

      # AWS SSO requires `bashcompinit` which needs to be enabled once and
      # only once in your shell.  Hence we do not include the two lines:
      #
      #
      # If you do not already have these lines, you must COPY the lines
      # above, place it OUTSIDE of the BEGIN/END_AWS_SSO_CLI markers
      # and of course uncomment it

      aws-sso-profile() {
          local _args=''${AWS_SSO_HELPER_ARGS:- -L error}
          if [ -n "$AWS_PROFILE" ]; then
              echo "Unable to assume a role while AWS_PROFILE is set"
              return 1
          fi

          if [ -z "$1" ]; then
              echo "Usage: aws-sso-profile <profile>"
              return 1
          fi

          eval $(/nix/store/s5s6si3kmz8k15vm9v6d5qk3mpa546cc-aws-sso-cli-1.17.0/bin/.aws-sso-wrapped ''${=_args} eval -p "$1")
          if [ "$AWS_SSO_PROFILE" != "$1" ]; then
              return 1
          fi
      }

      aws-sso-clear() {
          local _args=''${AWS_SSO_HELPER_ARGS:- -L error}
          if [ -z "$AWS_SSO_PROFILE" ]; then
              echo "AWS_SSO_PROFILE is not set"
              return 1
          fi
          eval $(/nix/store/s5s6si3kmz8k15vm9v6d5qk3mpa546cc-aws-sso-cli-1.17.0/bin/.aws-sso-wrapped ''${=_args} eval -c)
      }

      # END_AWS_SSO_CLI

      function direnv-new() {
        nix flake new -t github:nix-community/nix-direnv ./;
        direnv allow

        # Check if we're in a git repository
        if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
          # Determine the git root directory
          GIT_ROOT=$(git rev-parse --show-toplevel)
  
          # Path to the .gitignore file
          GITIGNORE_PATH="$GIT_ROOT/.gitignore"
  
          # Create .gitignore if it doesn't exist
          if [ ! -f "$GITIGNORE_PATH" ]; then
            touch "$GITIGNORE_PATH"
            echo "Created .gitignore file"
          fi
  
          # Check if .direnv is already in .gitignore
          if grep -q "^.direnv$\|^.direnv/$" "$GITIGNORE_PATH"; then
            echo ".direnv is already in .gitignore"
          else
            # Add .direnv to .gitignore
            echo ".direnv/" >> "$GITIGNORE_PATH"
            echo "Added '.direnv/' to .gitignore"
          fi
        else
          echo "Error: Not in a git repository"
          exit 1
        fi
      }

      # Function to get PR URL and copy using OSC52
      prl() {
        pr_url=$(gh pr view --json url --jq .url)
        if [ $? -eq 0 ]; then
          printf "\033]52;c;$(echo -n "$pr_url" | base64)\a"
          echo "PR URL copied to clipboard: $pr_url"
        else
          echo "Failed to get PR URL. Make sure you're in a git repository with an open PR."
        fi
      }

      # Function to edit PR description in your default editor
      # If PR_NUMBER is empty, default behaviour follows
      # Usage: predit [PR_NUMBER]
      prb() {
        # Check if gh is installed
        if ! command -v gh &> /dev/null; then
          echo "Error: GitHub CLI (gh) is not installed. Please install it first."
          return 1
        fi

        # Check if a PR number was provided as an argument, otherwise use current branch
        if [ "$1" ]; then
          PR_SELECTOR="$1"
        else
          PR_SELECTOR=""
        fi

        # Create a temporary file
        TEMP_FILE=$(mktemp /tmp/pr-body-XXXXXX.md)

        # Get the current PR body and save to the temporary file
        echo "Fetching current PR description..."
        gh pr view $PR_SELECTOR --json body --jq .body > "$TEMP_FILE"

        if [ $? -ne 0 ]; then
          echo "Error: Failed to get PR description. Make sure you're in a repository with a PR or provide a valid PR number."
          rm "$TEMP_FILE"
          return 1
        fi

        # Get the original file modification time
        ORIGINAL_MTIME=$(stat -c %Y "$TEMP_FILE" 2>/dev/null || stat -f %m "$TEMP_FILE")

        # Open the temporary file in the default editor
        echo "Opening PR description in your default editor. Make your changes and save the file..."
        $${VISUAL:-$${EDITOR:-vi}} "$TEMP_FILE"

        # Get the new file modification time
        NEW_MTIME=$(stat -c %Y "$TEMP_FILE" 2>/dev/null || stat -f %m "$TEMP_FILE")

        # Check if the file was modified
        if [ "$ORIGINAL_MTIME" = "$NEW_MTIME" ]; then
          echo "No changes were made. PR description not updated."
          rm "$TEMP_FILE"
          return 0
        fi

        # Update the PR body with the edited content
        echo "Updating PR description..."
        gh pr edit $PR_SELECTOR --body-file "$TEMP_FILE"

        if [ $? -eq 0 ]; then
          echo "PR description updated successfully!"
        else
          echo "Error: Failed to update PR description."
          echo "Your changes are saved in: $TEMP_FILE"
          return 1
        fi

        # Clean up
        rm "$TEMP_FILE"
      }

      # yazi
      function c() {
      	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
      	yazi "$@" --cwd-file="$tmp"
      	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      		builtin cd -- "$cwd"
      	fi
      	rm -f -- "$tmp"
      }
    '';

    shellAliases = {
      k = "kubectl";
      l = "ls -la";
      ll = "ls -la";
      ld = "lazydocker";
      cu = "cd .. && ll";
      zj = "zellij";
      nosleep = "sudo pmset -b disablesleep 1";
      yessleep = "sudo pmset -b disablesleep 0";
      prc = "gh pr comment --editor";
      pre = "gh pr comment --editor --edit-last";
      prv = "gh pr view --comments";
      prw = "gh pr view --web";
    };

  };
}

