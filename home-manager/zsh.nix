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
      l = "eza -la --icons --group-directories-first --git";
      ll = "eza -l --icons --group-directories-first --git";
      lt = "eza -laT --icons --group-directories-first --git --level=2";
      ls = "eza --icons --group-directories-first";

      update = "sudo nixos-rebuild switch --flake .#pxndxs";
      updatehome = "home-manager switch --flake .#pxndxs@pxndxs";

      confnix = "cd ~/.config/nixos";
      confvim = "cd ~/workspace/neocats";
      confhyp = "cd ~/.config/hypr";

      cat = "bat --style=auto";
      find = "fd";

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
      path = "${config.xdg.dataHome}/zsh/history";
    };

    initContent = ''
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
        color_staged_add="#22c55e"
        color_staged_change="#38bdf8"
        color_staged_delete="#fb7185"

        color_work_add="#9CFF2E"
        color_work_change="#9CDBA6"
        color_work_delete="#ef4444"
        color_push="#0D7C66"
        color_untracked="#E5B273"

        # Get git status in porcelain format (X=index/staged, Y=working tree)
        local git_status
        git_status=$(git status --porcelain=v1 2>/dev/null)

        local staged_added=0
        local staged_changed=0
        local staged_deleted=0
        local work_added=0
        local work_changed=0
        local work_deleted=0
        local untracked=0
        local unpushed=0

        if [[ -n "$git_status" ]]; then
          local parsed_status
          parsed_status=$(printf '%s\n' "$git_status" | awk '
            BEGIN { sa=0; sc=0; sd=0; wa=0; wc=0; wd=0; u=0 }
            /^\?\?/ { u++; next }
            {
              x = substr($0, 1, 1)
              y = substr($0, 2, 1)

              if (x == "A") sa++
              else if (x == "D") sd++
              else if (x != " " && x != "?") sc++

              if (y == "A") wa++
              else if (y == "D") wd++
              else if (y != " " && y != "?") wc++
            }
            END { printf "%d %d %d %d %d %d %d", sa, sc, sd, wa, wc, wd, u }
          ')
          read staged_added staged_changed staged_deleted work_added work_changed work_deleted untracked <<< "$parsed_status"
        fi

        if git rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then
          unpushed=$(git rev-list --count '@{upstream}..HEAD' 2>/dev/null)
        fi

        local output=""

        # Same icons for staged/working; color differentiates each area.
        [[ $staged_added -gt 0 ]] && output+="%F{$color_staged_add}$icon_add $staged_added %f"
        [[ $staged_changed -gt 0 ]] && output+="%F{$color_staged_change}$icon_change $staged_changed %f"
        [[ $staged_deleted -gt 0 ]] && output+="%F{$color_staged_delete}$icon_delete $staged_deleted %f"

        [[ $work_added -gt 0 ]] && output+="%F{$color_work_add}$icon_add $work_added %f"
        [[ $work_changed -gt 0 ]] && output+="%F{$color_work_change}$icon_change $work_changed %f"
        [[ $work_deleted -gt 0 ]] && output+="%F{$color_work_delete}$icon_delete $work_deleted %f"

        [[ $untracked -gt 0 ]] && output+="%F{$color_untracked}$icon_untracked $untracked %f"
        [[ $unpushed -gt 0 ]] && output+="%F{$color_push}$icon_push $unpushed %f"

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
