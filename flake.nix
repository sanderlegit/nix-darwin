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
	  pkgs.fzf
	  pkgs.ripgrep
	  pkgs.fzf-obc
	  pkgs.fzf-make
	  pkgs.fzf-git-sh
	  pkgs.helix
	  pkgs.nil
        ];

      # Create /etc/zshrc that loads the nix-darwin environment.
      # this is required if you want to use darwin's default shell - zsh
      homebrew = {
        enable = true;
        brews = [
          "mas"
        ];
        casks = [
	  "wget"
	  "curl"
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

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
          # Set up applications.
          echo "setting up /Applications..." >&2
          rm -rf /Applications/Nix\ Apps
          mkdir -p /Applications/Nix\ Apps
          find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
          while read -r src; do
            app_name=$(basename "$src")
            echo "copying $src" >&2
            ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
          done
        '';

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

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Enable Oh-my-zsh
      # programs.zsh.ohMyZsh = {
      #   enable = true;
      #   plugins = [ "git" "sudo" "docker" "kubectl" ];
      # };

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
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
