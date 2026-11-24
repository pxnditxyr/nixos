{ pkgs, config, lib, platform, ... }:
let
  copyChar = text:
    if platform.isDarwin then
      ''echo -n "${text}" | pbcopy''
    else ''
      if [[ $WAYLAND_DISPLAY && $WAYLAND_DISPLAY != "wayland-0" ]]; then
        echo -n "${text}" | wl-copy
      else
        echo -n "${text}" | xclip -selection clipboard
      fi
    '';

  baseAliases = {
    l  = "eza -la --icons --group-directories-first --git";
    ll = "eza -l --icons --group-directories-first --git";
    lt = "eza -laT --icons --group-directories-first --git --level=2";
    ls = "eza --icons --group-directories-first";

    confnix = "cd ~/.config/nixos";

    cat  = "bat --style=auto";
    find = "fd";

    "57" = copyChar "6";
    nn   = copyChar "ñ";
    aa   = copyChar "á";
    ee   = copyChar "é";
    ii   = copyChar "í";
    oo   = copyChar "ó";
    uu   = copyChar "ú";
    v    = "npd";
  };

  linuxAliases = {
    confhyp = "cd ~/.config/hypr";
  };
in
{
  home.packages = [ pkgs.gum ]; # used by zsh/nix-helpers.zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    # Only omz's git aliases, without the framework; lib/git.zsh defines the
    # helpers they call (git_current_branch, …).
    plugins = [
      # Without omz, add-zsh-hook isn't autoloaded; the async prompt is unused.
      {
        name = "omz-git-prelude";
        src = pkgs.writeTextDir "omz-git-prelude.zsh" ''
          autoload -Uz add-zsh-hook is-at-least
          zstyle ':omz:alpha:lib:git' async-prompt no
        '';
        file = "omz-git-prelude.zsh";
      }
      {
        name = "omz-git-lib";
        src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/lib";
        file = "git.zsh";
      }
      {
        name = "omz-git";
        src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/git";
        file = "git.plugin.zsh";
      }
    ];

    shellAliases = baseAliases // lib.optionalAttrs (!platform.isDarwin) linuxAliases;

    history = {
      size = 100000;
      save = 100000;
      path = "${config.xdg.dataHome}/zsh/history";
      share = true;
      extended = true;
      ignoreAllDups = true;
      expireDuplicatesFirst = true;
      ignoreSpace = true;
    };

    initContent = lib.mkMerge [
      # fzf-tab: after compinit (570), before autosuggestions (700).
      (lib.mkOrder 600 ''
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        zstyle ':completion:*' menu no
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath'
      '')

      ''
      # macOS updates reset /etc/zshrc and drop the Nix installer's hook.
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi

      if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
        unset __HM_SESS_VARS_SOURCED
        source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      fi

      # Treat / as a word separator for delete-word.
      WORDCHARS="";

      source ${./zsh/nix-helpers.zsh}

      eval "$(fnm env --use-on-cd --shell zsh)"

      typeset -U path
      for _dir in $HOME/.*/bin(N/); do
        path+=("$_dir")
      done
      unset _dir
    ''

      # After HM aliases (1100) so local ones win; before highlighting (1200).
      (lib.mkOrder 1150 ''
        [[ -r ~/.zshrc.local ]] && source ~/.zshrc.local
      '')
    ];
  };
  home.sessionPath = [ "$HOME/.local/bin" ];
}
