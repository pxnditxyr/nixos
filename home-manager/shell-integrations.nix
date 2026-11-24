# Tools that need a binary plus a shell hook; don't also list them in home.packages.
{ pkgs, ... }: {
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      pager = "less -FR";
    };
  };

  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
  };

  # 🐼 Pxndxs prompt — panda layout, neon palette ❄️
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      format = "🐼 $username  $directory$git_branch$git_status  ";

      username = {
        show_always = true;
        format = "[$user]($style) ";
        style_user = "fg:#00FFC6";
        style_root = "fg:#FF5722";
      };

      directory = {
        format = "[$path]($style)[$read_only]($read_only_style) ";
        style = "fg:#EA047E";
        truncation_length = 100;
        truncate_to_repo = false;
        home_symbol = "~";
      };

      git_branch = {
        format = "[ \\($branch\\) ]($style)";
        style = "fg:#FFED00";
      };

      git_status = {
        format = "$conflicted$staged$modified$renamed$deleted$untracked$stashed$ahead_behind";
        conflicted = "[󰞇 $count ](fg:#FF5722)";
        renamed = "[󰑕 $count ](fg:#38bdf8)";
        stashed = "[󰏗 $count ](fg:#a78bfa)";
        staged = "[󱝹 $count ](fg:#22c55e)";
        modified = "[󰏫 $count ](fg:#9CDBA6)";
        deleted = "[󱂧 $count ](fg:#ef4444)";
        untracked = "[󱛑 $count ](fg:#E5B273)";
        ahead = "[󱖉 $count ](fg:#0D7C66)";
        diverged = "[󱖉 $ahead_count ](fg:#0D7C66)";
        behind = "";
      };
    };
  };
}
