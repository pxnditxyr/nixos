{ pkgs, config, ... }:
{
  home.packages = [ pkgs.zsh ];
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
      ];
    };

    shellAliases = {
      # Modern ls replacement with eza (better colors, git integration, icons)
      l = "eza -la --icons --group-directories-first --git";
      ll = "eza -l --icons --group-directories-first --git";
      lt = "eza -laT --icons --group-directories-first --git --level=2";
      ls = "eza --icons --group-directories-first";
      
      # System management
      update = "sudo nixos-rebuild switch --flake .#pxndxs";
      updatehome = "home-manager switch --flake .#pxndxs@pxndxs";
      
      # Quick navigation
      confnix = "cd ~/.config/nixos";
      confvim = "cd ~/workspace/neocats";
      confhyp = "cd ~/.config/hypr";
      
      # Modern tools (use \command to bypass alias, e.g., \cat, \grep)
      cat = "bat --style=auto";
      find = "fd";
      # grep = "rg";  # Comentado para evitar conflictos con scripts que usan grep -E
      # Usa 'rg' directamente cuando busques en archivos
      "57" = ''
        if [[ $WAYLAND_DISPLAY && $WAYLAND_DISPLAY != "wayland-0" ]]; then
          echo -n "6" | wl-copy
        else
          echo -n "6" | xclip -selection clipboard
        fi
      '';
      nn = ''
        if [[ $WAYLAND_DISPLAY && $WAYLAND_DISPLAY != "wayland-0" ]]; then
          echo -n "ñ" | wl-copy
        else
          echo -n "ñ" | xclip -selection clipboard
        fi
      '';
      aa = ''
        if [[ $WAYLAND_DISPLAY && $WAYLAND_DISPLAY != "wayland-0" ]]; then
          echo -n "á" | wl-copy
        else
          echo -n "á" | xclip -selection clipboard
        fi
      '';
      ee = ''
        if [[ $WAYLAND_DISPLAY && $WAYLAND_DISPLAY != "wayland-0" ]]; then
          echo -n "é" | wl-copy
        else
          echo -n "é" | xclip -selection clipboard
        fi
      '';
      ii = ''
        if [[ $WAYLAND_DISPLAY && $WAYLAND_DISPLAY != "wayland-0" ]]; then
          echo -n "í" | wl-copy
        else
          echo -n "í" | xclip -selection clipboard
        fi
      '';
      oo = ''
        if [[ $WAYLAND_DISPLAY && $WAYLAND_DISPLAY != "wayland-0" ]]; then
          echo -n "ó" | wl-copy
        else
          echo -n "ó" | xclip -selection clipboard
        fi
      '';
      uu = ''
        if [[ $WAYLAND_DISPLAY && $WAYLAND_DISPLAY != "wayland-0" ]]; then
          echo -n "ú" | wl-copy
        else
          echo -n "ú" | xclip -selection clipboard
        fi
      '';
      v = "neocats";
    };

    history = {
      size = 10000;
      path = "${ config.xdg.dataHome }/zsh/history";
    };
    
    initExtra = ''
    # colors
    NAME_COLOR='#00FFC6';
    FIRST_PAW_COLOR='#85EF47';
    SECOND_PAW_COLOR='#FF5722';
    DIR_COLOR='#EA047E';

    function git_branch_name () {
      color_git="#FFED00";
      icon_git=" "
      branch=$(git symbolic-ref HEAD 2> /dev/null | awk 'BEGIN{FS="/"} {print $NF}')
      local output=""
      if [[ $branch == "" ]]; then
        output=""
      else
        output="%F{$color_git}$icon_git($branch) %f"
      fi
      echo $output
    }

    function git_status_summary_xd () {
      # Define icons
      icon_add="󱝹"
      icon_change=""
      icon_delete="󱂧"
      icon_push="󱖉"
      icon_untracked="󱛑"

      # Define colors
      color_add="#9CFF2E"
      color_change="#9CDBA6"
      color_delete="#ef4444"
      color_push="#0D7C66"
      color_untracked="#E5B273"

      # Get git status counts with proper parsing
      local git_status=$(git status --porcelain=v1 2>/dev/null)
      
      # Count files properly:
      # First column = staging area, Second column = working directory
      # A  = added to staging
      # M  = modified in staging
      #  M = modified in working directory
      # ?? = untracked
      # D  = deleted
      # Using /bin/grep to avoid conflicts with rg alias
      local added=$(echo "$git_status" | /bin/grep -E '^A[ MD]' | wc -l)
      local changed=$(echo "$git_status" | /bin/grep -E '^[ MARC]M' | wc -l)
      local deleted=$(echo "$git_status" | /bin/grep -E '^[ MARC]?D' | wc -l)
      local unpushed=$(git log --branches --not --remotes 2>/dev/null | /bin/grep '^commit' | wc -l)
      local untracked=$(echo "$git_status" | /bin/grep '^\?\?' | wc -l)

      local output=""

      [[ $added -gt 0 ]] && output+="%F{$color_add}$icon_add $added %f"
      [[ $changed -gt 0 ]] && output+="%F{$color_change}$icon_change $changed %f"
      [[ $deleted -gt 0 ]] && output+="%F{$color_delete}$icon_delete $deleted %f"
      [[ $unpushed -gt 0 ]] && output+="%F{$color_push}$icon_push $unpushed %f"
      [[ $untracked -gt 0 ]] && output+="%F{$color_untracked}$icon_untracked $untracked %f"

      echo $output
    }

    PROMPT="🐼 "
    PROMPT+="%F{$NAME_COLOR}%n ";
    PROMPT+="%F{$FIRST_PAW_COLOR}  ";
    PROMPT+="%F{$DIR_COLOR}%~ ";
    PROMPT+='$(git_branch_name)$(git_status_summary_xd)';
    PROMPT+="%F{$SECOND_PAW_COLOR}  %f";

    # setting for take in account / like a word separator in delete word
    WORDCHARS="";
    
    # fnm - Fast Node Manager
    eval "$(fnm env --use-on-cd --shell zsh)"
    
    # zoxide - smarter cd command (use 'z' instead of 'cd')
    eval "$(zoxide init zsh)"
    '';
  };
}
