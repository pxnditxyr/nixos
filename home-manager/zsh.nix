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
      v = "nvim";
    };

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
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
