{ pkgs, config, ... }:
{
  home.packages = [ pkgs.zsh ];
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      l = "LC_COLLATE=C ls -la --color=auto --group-directories-first --block-size=M";
      update = "sudo nixos-rebuild switch --flake .#pxndxs";
      updatehome = "home-manager switch --flake .#pxndxs@pxndxs";
      confnix = "cd ~/Documents/nix-config";
      confvim = "cd ~/.config/nvim";
      confhyp = "cd ~/.config/hypr";
      "57" = ''
        if [[ $WAYLAND_DISPLAY ]]; then
          echo -n "6" | wl-copy
        else
          echo -n "6" | xclip -selection clipboard
        fi
      '';
      nn = ''
        if [[ $WAYLAND_DISPLAY ]]; then
          echo -n "ñ" | wl-copy
        else
          echo -n "ñ" | xclip -selection clipboard
        fi
      '';
      aa = ''
        if [[ $WAYLAND_DISPLAY ]]; then
          echo -n "á" | wl-copy
        else
          echo -n "á" | xclip -selection clipboard
        fi
      '';
      ee = ''
        if [[ $WAYLAND_DISPLAY ]]; then
          echo -n "é" | wl-copy
        else
          echo -n "é" | xclip -selection clipboard
        fi
      '';
      ii = ''
        if [[ $WAYLAND_DISPLAY ]]; then
          echo -n "í" | wl-copy
        else
          echo -n "í" | xclip -selection clipboard
        fi
      '';
      oo = ''
        if [[ $WAYLAND_DISPLAY ]]; then
          echo -n "ó" | wl-copy
        else
          echo -n "ó" | xclip -selection clipboard
        fi
      '';
      uu = ''
        if [[ $WAYLAND_DISPLAY ]]; then
          echo -n "ú" | wl-copy
        else
          echo -n "ú" | xclip -selection clipboard
        fi
      '';
      v = "nvim";
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
    GIT_COLOR='#FFED00';

    # functions for git branch
    function git_branch_name () {
      branch=$(git symbolic-ref HEAD 2> /dev/null | awk 'BEGIN{FS="/"} {print $NF}')
      if [[ $branch == "" ]]; then
        :
      else
        echo '\uE0A0(' $branch ') '
      fi
    }

    prompt="%F{$NAME_COLOR}%n %F{$FIRST_PAW_COLOR}  %F{$DIR_COLOR}%c %F{$GIT_COLOR}\ $(git_branch_name) %F{$SECOND_PAW_COLOR}  %f";
    # setting for take in account / like a word separator in delete word
    WORDCHARS="";
    '';
  };
}
