{
  description = "Dreams of Code Zenful macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, config, ... }: {

      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          pkgs.alacritty
          pkgs.mkalias
          pkgs.neovim
          pkgs.obsidian
          pkgs.tmux
          pkgs.zellij
          pkgs.lazygit
          pkgs.zsh
          pkgs.fzf
          pkgs.ripgrep
          pkgs.zsh-fzf-tab
          pkgs.fzf-obc
          pkgs.fzf-make
          pkgs.fzf-git-sh
          pkgs.helix
      	  pkgs.nil
          pkgs.nushell
          pkgs.yazi
          pkgs.broot

          pkgs.kubectl
        ];

      # Create /etc/zshrc that loads the nix-darwin environment.
      # this is required if you want to use darwin's default shell - zsh
      homebrew = {
        enable = true;
        brews = [
      	  "wget"
      	  "curl"
          "mas"
        ];
        casks = [
      	  #"aria2"
      	  #"httpie"
      	  #"insomnia"
      	  #"wireshark"
          "hammerspoon"
          "firefox"
          "iina"
          "the-unarchiver"
          "alacritty"
          "ghostty"
      	  "signal"
      	  "keepassxc"
      	  "topnotch"
      	  "betterdisplay"
      	  "vivid"
        ];
        masApps = {
          # "Yoink" = 457622435;
        };
        onActivation.cleanup = "zap";
      };

    # system.activationScripts.applications.text = let
    #   env = pkgs.buildEnv {
    #     name = "system-applications";
    #     paths = config.environment.systemPackages;
    #     pathsToLink = "/Applications";
    #   };
    # in
    #   pkgs.lib.mkForce ''
    #     # Set up applications.
    #     echo "setting up /Applications..." >&2
    #     rm -rf /Applications/Nix\ Apps
    #     mkdir -p /Applications/Nix\ Apps
    #     find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
    #     while read -r src; do
    #       app_name=$(basename "$src")
    #       echo "copying $src" >&2
    #       ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
    #     done
    #   '';

      # https://daiderd.com/nix-darwin/manual/index.html
     #system.defaults = {
     #  dock.autohide  = true;
     #  dock.largesize = 32;
     #  dock.persistent-apps = [
     #    "/Applications/Ghostty.app"
     #    "/Applications/Firefox.app"
     #    "/System/Applications/Mail.app"
     #    "/System/Applications/Calendar.app"
     #    "/Applications/Signal.app"
     #    "/Applications/KeePassXC.app"
     #  ];
     #  finder.FXPreferredViewStyle = "clmv";
     #  loginwindow.GuestEnabled  = false;
     #  NSGlobalDomain.AppleICUForce24HourTime = true;
     #  NSGlobalDomain.AppleInterfaceStyle = "Dark";
     #  NSGlobalDomain.InitialKeyRepeat = 10;
     #  NSGlobalDomain.KeyRepeat = 2;
     #};

      # Add ability to used TouchID for sudo authentication
      # security.pam.enableSudoTouchIdAuth = true;

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

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
        '';
      };
      environment.shells = [ pkgs.zsh ];


      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."m4" = nix-darwin.lib.darwinSystem {
      modules = [
        ./modules/system.nix

        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            # Apple Silicon Only
            enableRosetta = true;
            # User owning the Homebrew prefix
            user = "sander";
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."m4".pkgs;
  };
}
