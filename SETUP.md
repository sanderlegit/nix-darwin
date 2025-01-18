 
github.com/LnL7/nix-darwin#getting-started
github.com/elliottminns/nix/blob/main/flake.nix

```
nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/nix#m4
darwin-rebuild switch --flake ~/nix#m4
```
