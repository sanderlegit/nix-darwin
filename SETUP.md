# Nix Darwin

## CLI tooling
- zsh
  - fzf search and completion
    ctrl-t, ctrl-r, alt-c
- multiplex and editor
  - hx, nvim, zellij, tmux
- file explore and git
  - yazi, broot, lazygit
- aerospace, window manager
  - `open /Applications/Nix\ Apps/AeroSpace.app`
  - see .aerospace.toml for bindings
- sane MacOS System defaults.
- terminals
  - alacritty, ghostty

## GUI Apps (Brew)
Some applications are installed as brew casks, appear in `/Applications` or `/Applications/Nix\ Apps`

- Signal
- Firefox
- KeePassXC
- ...

## Aerospace Window Manager Basics

```
# See: https://nikitabobko.github.io/AeroSpace/commands#workspace
# Works with 0-9 A-Z
alt-1 = 'workspace 1'

# See: https://nikitabobko.github.io/AeroSpace/commands#move-node-to-workspace
# Works with 0-9 A-Z
alt-shift-1 = 'move-node-to-workspace 1'

# See: https://nikitabobko.github.io/AeroSpace/commands#workspace-back-and-forth
alt-tab = 'workspace-back-and-forth'
# See: https://nikitabobko.github.io/AeroSpace/commands#move-workspace-to-monitor
alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'

# See: https://nikitabobko.github.io/AeroSpace/commands#layout
alt-slash = 'layout tiles horizontal vertical'
alt-comma = 'layout accordion horizontal vertical'

# See: https://nikitabobko.github.io/AeroSpace/commands#focus
alt-h = 'focus left'
alt-j = 'focus down'
alt-k = 'focus up'
alt-l = 'focus right'

# See: https://nikitabobko.github.io/AeroSpace/commands#move
alt-shift-h = 'move left'
alt-shift-j = 'move down'
alt-shift-k = 'move up'
alt-shift-l = 'move right'
```

## Setup
```
# Install Nix
# https://nixos.org/download/
sh <(curl -L https://nixos.org/nix/install)

# Clone config
git clone https://github.com/sanderlegit/nix-darwin.git ~/nix

# Install the config
nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/nix#m4

# Reload config ( works after 1st installation )
darwin-rebuild switch --flake ~/nix#m4

# Optional, Clone dotfiles
git clone -b linux https://github.com/sanderlegit/dotfiles.git ~/dotfiles

# Symlink config files and dirs as desired
ln -s ~/.config/helix ~/dotfiles/home/.config/helix
ln -s ~/.config/zellij ~/dotfiles/home/.config/zellij
ln -s ~/.aerospace.toml ~/dotfiles/home/.aerospace.toml
```

## Todo

- [ ] Look for better dotfile management method
  - still using a dotfiles repo with symlinks
    - stow or chezmoi similar
  - home-manager seems complex
- [ ] Figure out a better way to compose zshrc
- [ ] Understand if/how to alter nix system pkg defaults, and find config docs
- [ ] Declarative / stored firefox?
  - https://support.mozilla.org/en-US/kb/profiles-where-firefox-stores-user-data
  - https://support.mozilla.org/en-US/questions/1176169
  - https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265/7

## Docs
- https://github.com/LnL7/nix-darwin#getting-started
- https://daiderd.com/nix-darwin/manual/index.html

## Example Configs
- https://github.com/elliottminns/nix
- https://github.com/ryan4yin/nix-darwin-kickstarter
- https://github.com/knl/dotskel
- https://github.com/shaunsingh/nix-darwin-dotfiles
- https://github.com/AlexNabokikh/nix-config
