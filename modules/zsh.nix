{ pkgs, ... }:

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
    #enable = true;
    interactiveShellInit = '''';
  };
}
