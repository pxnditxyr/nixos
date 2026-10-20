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
    confvim = "cd ~/workspace/neocats";

    cat  = "bat --style=auto";
    find = "fd";

    "57" = copyChar "6";
    nn   = copyChar "ñ";
    aa   = copyChar "á";
    ee   = copyChar "é";
    ii   = copyChar "í";
    oo   = copyChar "ó";
    uu   = copyChar "ú";
    v    = "neocats";
  };

  linuxAliases = {
    confhyp = "cd ~/.config/hypr";
  };
in
{
  home.packages = [ pkgs.gum ]; # UI for zsh/nix-helpers.zsh (zsh itself comes from programs.zsh)
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    # No oh-my-zsh framework: HM wires compinit/autosuggestions/highlighting
    # itself. Only the omz git aliases (gst, gco, gp, …) are kept; lib/git.zsh
    # provides the helpers they call (git_current_branch, …).
    plugins = [
      # lib/git.zsh registers an async prompt helper via add-zsh-hook; without
      # the omz framework the hook isn't autoloaded, and we don't use omz's
      # prompt anyway (starship / Warp), so turn it off.
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
      share = true;                 # live history across open shells
      extended = true;              # timestamps + durations
      ignoreAllDups = true;
      expireDuplicatesFirst = true;
      ignoreSpace = true;           # ` cmd` stays out of history
    };

    initContent = lib.mkMerge [
      # fzf-tab must load after compinit (570) and before widget-wrapping
      # plugins like zsh-autosuggestions (700).
      (lib.mkOrder 600 ''
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        zstyle ':completion:*' menu no
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath'
      '')

      ''
      # macOS resets /etc/zshrc on every OS update, wiping whatever shell
      # integration the Nix installer put there. Source nix-daemon.sh
      # directly from our own (user-owned, update-proof) .zshrc instead of
      # depending on /etc/zshrc surviving reboots.
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi

      if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
        unset __HM_SESS_VARS_SOURCED
        source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      fi

      # setting for take in account / like a word separator in delete word
      WORDCHARS="";

      # Nix helpers (hms, nrs, nfu, nclean, nsearch, ngen) with a gum UI.
      source ${./zsh/nix-helpers.zsh}

      # fnm - Fast Node Manager
      eval "$(fnm env --use-on-cd --shell zsh)"

      typeset -U path
      for _dir in $HOME/.*/bin(N/); do
        path+=("$_dir")
      done
      unset _dir
    ''
    ];
  };
  home.sessionPath = [ "$HOME/.local/bin" ];
}
