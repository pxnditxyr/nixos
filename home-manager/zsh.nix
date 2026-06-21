{ pkgs, config, lib, platform, ... }:
let
  # Single platform-aware clipboard helper. Darwin → pbcopy. Linux → dispatch
  # between wl-copy (Wayland session) and xclip (X11 fallback) at runtime.
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

  # `update` / `updatehome` are now shell FUNCTIONS (see initContent) — they
  # auto-detect host/OS/user at runtime and accept an optional explicit profile.
  # Only the Linux-only directory shortcut remains an alias here.
  linuxAliases = {
    confhyp = "cd ~/.config/hypr";
  };
in
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

    shellAliases = baseAliases // lib.optionalAttrs (!platform.isDarwin) linuxAliases;

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    initContent = ''
      if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
        unset __HM_SESS_VARS_SOURCED
        source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      fi

      # colors
      NAME_COLOR='#00FFC6';
      FIRST_PAW_COLOR='#85EF47';
      SECOND_PAW_COLOR='#FF5722';
      DIR_COLOR='#EA047E';

      function git_branch_name () {
        color_git="#FFED00";
        icon_git=" "
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
        icon_change=""
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
      PROMPT+="%F{$FIRST_PAW_COLOR}  ";
      PROMPT+="%F{$DIR_COLOR}%~ ";
      PROMPT+='$(git_branch_name)$(git_status_summary_xd)';
      PROMPT+="%F{$SECOND_PAW_COLOR}  %f";

      # setting for take in account / like a word separator in delete word
      WORDCHARS="";

      # ── Nix rebuild helpers ─────────────────────────────────────────────
      # update     → SYSTEM layer (nixos-rebuild), NixOS only
      # updatehome → USER layer (home-manager), all platforms
      # Strictly separate; never chained. Both auto-detect host/OS/user and
      # accept an optional explicit profile argument. nixprofiles lists keys.
      typeset -g _NIX_FLAKE="$HOME/.config/nixos"
      typeset -g _NIX_PROFILE_CACHE="''${XDG_CACHE_HOME:-$HOME/.cache}/nix-home-profiles"

      # True only on NixOS — hostname-independent (reads /etc/os-release ID).
      function _is_nixos() {
        [[ -r /etc/os-release ]] && grep -q '^ID=nixos' /etc/os-release
      }

      # Auto-derive the home-manager flake profile key for THIS environment.
      #   macOS       → $USER@mac
      #   NixOS       → $USER@<hostname>   (declarative hostname → matches key)
      #   other Linux → $USER@ubuntu-mac   (fixed; NO hostname match required)
      function _hm_profile() {
        if [[ "$OSTYPE" == darwin* ]]; then
          echo "''${USER}@mac"
        elif _is_nixos; then
          echo "''${USER}@$(hostname -s)"
        else
          echo "''${USER}@ubuntu-mac"
        fi
      }

      # List homeConfigurations keys. Cached; refreshes when flake.lock changes
      # or on `nixprofiles --refresh`. Avoids a ~1-2s nix eval on every switch.
      function nixprofiles() {
        local lock="''${_NIX_FLAKE}/flake.lock"
        if [[ "$1" == "--refresh" || ! -s "$_NIX_PROFILE_CACHE" || "$lock" -nt "$_NIX_PROFILE_CACHE" ]]; then
          mkdir -p "''${_NIX_PROFILE_CACHE:h}"
          nix eval "''${_NIX_FLAKE}#homeConfigurations" \
            --apply 'builtins.attrNames' --json 2>/dev/null \
            | tr -d '[]"' | tr ',' '\n' > "$_NIX_PROFILE_CACHE"
        fi
        cat "$_NIX_PROFILE_CACHE"
      }

      # USER layer only. Optional positional arg = explicit profile; default =
      # auto-detected. Validated against real flake keys. Never chained.
      function updatehome() {
        local profile="''${1:-$(_hm_profile)}"
        if ! nixprofiles | grep -qx "$profile"; then
          echo "❌ unknown profile '$profile'" >&2
          echo "valid: $(nixprofiles | paste -sd, -)" >&2
          return 1
        fi
        echo "🏠 home-manager switch → #''${profile}"
        home-manager switch --flake "''${_NIX_FLAKE}#''${profile}" -b backup
      }

      # SYSTEM layer only (nixos-rebuild). NixOS exclusively.
      # Optional positional arg = explicit host; default = current hostname.
      function update() {
        if ! _is_nixos; then
          echo "❌ update: nixos-rebuild is NixOS-only. Use 'updatehome' for the user layer." >&2
          return 1
        fi
        local host="''${1:-$(hostname -s)}"
        echo "❄️  nixos-rebuild switch → #''${host}"
        sudo nixos-rebuild switch --flake "''${_NIX_FLAKE}#''${host}"
      }

      # Tab-completion: `updatehome <TAB>` → flake profile keys.
      # NOTE: works in real-zsh terminals (Terminal.app, kitty, ghostty).
      # Warp uses its own completion engine and may ignore this.
      function _updatehome() {
        local -a profiles
        profiles=(''${(f)"$(nixprofiles 2>/dev/null)"})
        compadd -a profiles
      }
      compdef _updatehome updatehome

      # fnm - Fast Node Manager
      eval "$(fnm env --use-on-cd --shell zsh)"

      # zoxide init handled by ../home-manager/shell-integrations.nix
      # (programs.zoxide.enableZshIntegration = true)
    '';
  };
  home.sessionPath = [ "$HOME/.local/bin" ];
}
