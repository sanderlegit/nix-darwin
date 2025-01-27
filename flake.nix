{
  description = "Dreams of Code Zenful macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, nix-homebrew }:
  let
      # TODO replace with your own username, email, system, and hostname
    username = "sander";
    useremail = "sander@aaadataplumbing.com";
    system = "aarch64-darwin";
    hostname = "lattice";

    specialArgs =
      inputs
      // {
        inherit username useremail hostname;
      };
    configuration = { pkgs, config, ... }: {

      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          # fix aliases for macos
          pkgs.mkalias

          pkgs.alacritty     # terminal
          pkgs.lazygit
          pkgs.aerospace     # i3 style windows
          pkgs.tmux          # multiplex term
          pkgs.zellij        # multiplex term
          pkgs.helix         # editor
          pkgs.neovim        # editor
          pkgs.nil           # nix lsp
          pkgs.yazi          # file explore
          pkgs.broot         # file explore
          pkgs.zsh
          pkgs.oh-my-zsh
          # pkgs.starship
          pkgs.skim
          pkgs.fzf
          pkgs.ripgrep
          pkgs.fzf-obc
          pkgs.fzf-make
          pkgs.fzf-git-sh
          pkgs.nushell
          pkgs.sd            # better sed
          pkgs.fd            # better find
          pkgs.bat           # better cat
          pkgs.bottom        # sysmonitor
          pkgs.du-dust       # diskusage
          pkgs.mosh          # betterssh
          # pkgs.docker        # macos also needs  https://docs.docker.com/desktop/release-notes/
          pkgs.dive          # docker inspect
          pkgs.kubectl
          # pkgs.helm # not supported, using brew
          pkgs.minikube
          pkgs.k9s
          pkgs.ollama        # local ml
          pkgs.awscli2
          pkgs.awsls
          pkgs.aws-sam-cli   # lambda cli
          pkgs.gh
          pkgs.aws-sso-cli

          ## Go
          pkgs.go
          pkgs.gopls
          pkgs.protobuf
          pkgs.protoc-gen-go
          pkgs.protoc-gen-go-grpc
          pkgs.protoc-gen-rust
          pkgs.protoc-gen-rust-grpc
          pkgs.protoc-gen-tonic
          pkgs.protoc-gen-prost

          ## Rust
          # run to setup toolcahin
          # $ rustup default stable
          # $ rustup component add rust-analyzer
          pkgs.rustup
          pkgs.clippy

          ## TS
          pkgs.nodejs_22
          pkgs.typescript-language-server

          ## Py
          # run, to create venv with py version, and edit pyproject toml
          # $ python3.11 -m venv "venv"
          # $ source ./venv/bin/activate
          # $ poetry init
          # $ poetry add {pkg}
           
          # run, when in dir of pyproject.toml
          # $ poetry env use python
          # $ poetry install
          # $ $(poetry env activate)
          pkgs.poetry
          pkgs.python3
          pkgs.python3Packages.virtualenv
          pkgs.python311
          pkgs.python312
          pkgs.python312Packages.pip
          pkgs.python312Packages.ruff
          pkgs.python312Packages.python-lsp-server
          pkgs.python312Packages.jedi-language-server

        ];

      # Create /etc/zshrc that loads the nix-darwin environment.
      # this is required if you want to use darwin's default shell - zsh
      homebrew = {
        enable = true;
        brews = [
      	  "wget"
      	  "curl"
          "mas"
          "helm"
          "patchelf"
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
          "mullvadvpn"
          "slack"
          "spotify"
          "whatsapp"
          "karabiner-elements"
        ];
        masApps = {
          # "Yoink" = 457622435;
        };
        onActivation.cleanup = "zap";
      };

      nixpkgs.overlays = [
        (import ./overlays/helix.nix)
      ];

      # Add ability to used TouchID for sudo authentication
      # security.pam.enableSudoTouchIdAuth = true;

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

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
        ./modules/zsh.nix

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

        # home manager
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users.sander = import ./home;
          users.users.sander.home = "/Users/sander";
        }

      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."m4".pkgs;
  };
}
