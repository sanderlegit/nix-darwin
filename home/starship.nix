{ config, pkgs, lib, ... }: {
  programs.starship = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;

      format = lib.concatStrings [
        "$time"
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_state"
        "$git_status"
        "$cmd_duration"
        "$line_break"
        "$python"
        "$character"
      ];

      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
        vimcmd_symbol = "[❮](green)";
      };

      directory = {
        style = "blue";
        truncation_length = 3;
        truncate_to_repo = true;
      };

      git_branch = {
        format = "[$branch]($style) ";
        style = "italic white";
      };

      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style) ";
        style = "cyan";
        conflicted = "";
        untracked = "​";
        modified = "​";
        staged = "​";
        renamed = "​";
        deleted = "​";
        stashed = "≡";
      };

      git_state = {
        format = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
        style = "bright-black";
      };

      cmd_duration = {
        format = "[$duration]($style) ";
        style = "yellow";
        min_time = 500;
      };

      python = {
        format = "[$virtualenv]($style) ";
        style = "bright-black";
      };

      hostname = {
        ssh_only = false;
        format = "[$hostname]($style) - ";
        style = "bright-black";
      };

      username = {
        style_user = "bright-black";
        style_root = "red";
        format = "[$user]($style) ";
        show_always = false;
      };

      time = {
        disabled = false;
        format = "[\\[$time\\]]($style) ";
        time_format = "%T";
        utc_time_offset = "1";
        style = "yellow";
        # time_range = "10:00:00-14:00:00"; # Note: time_range requires Starship v1.1.0+
      };
      aws = {
        format = "on [$symbol$active(\($region\))]($style) ";
        symbol = "🅰 ";
      };

      gcloud = {
        # do not show the account/project's info
        # to avoid the leak of sensitive information when sharing the terminal
        format = "on [$symbol$active(\($region\))]($style) ";
        symbol = "🅶 ️";
      };
    };
  };
}
