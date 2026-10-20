# Hyprland session layer: Lua config, helper scripts and the small user
# services the config relies on. Hyprland itself comes from NixOS
# (programs.hyprland in nixos/configuration.nix).
{ pkgs, ... }:
let
  # Helper scripts as real packages: writeShellApplication adds
  # `set -euo pipefail`, runs shellcheck at build time and pins every
  # dependency via runtimeInputs, so a missing tool fails the build instead
  # of failing silently at keypress time.
  rofiCalc = pkgs.writeShellApplication {
    name = "hypr-rofi-calc";
    runtimeInputs = with pkgs; [ rofi libqalculate wl-clipboard libnotify ];
    text = ''
      while :; do
        calc=$(rofi -dmenu -p "Calculator" -theme-str 'window {width: 50%;}' || true)
        [ -n "$calc" ] || exit 0

        # -t: terse, print only the result (not "expr = result").
        result=$(qalc -t "$calc" 2>/dev/null | tail -n 1)

        action=$(printf '%s\n' "Copy to clipboard" "New calculation" \
          | rofi -dmenu -p "Result: $result" || true)
        case $action in
          "Copy to clipboard")
            printf '%s' "$result" | wl-copy
            notify-send "Calculator" "Result copied: $result"
            exit 0 ;;
          "New calculation") continue ;;
          *) exit 0 ;;
        esac
      done
    '';
  };

  webSearch = pkgs.writeShellApplication {
    name = "hypr-web-search";
    runtimeInputs = with pkgs; [ rofi jq xdg-utils ];
    text = ''
      query=$(rofi -dmenu -p " " -theme-str 'window {width: 50%;}' || true)
      [ -n "$query" ] || exit 0

      # URL: explicit scheme, or one word that looks like a domain
      # ("node.js docs" has a space, so it is a search).
      if [[ $query =~ ^https?:// ]]; then
        xdg-open "$query"
      elif [[ $query != *" "* && $query =~ \.[a-zA-Z]{2,}(/|$) ]]; then
        xdg-open "https://$query"
      else
        xdg-open "https://www.google.com/search?q=$(jq -rn --arg q "$query" '$q | @uri')"
      fi
    '';
  };

  wallpaperPicker = pkgs.writeShellApplication {
    name = "hypr-wallpaper";
    runtimeInputs = with pkgs; [ rofi awww libnotify findutils coreutils ];
    text = ''
      dir="$HOME/.config/hypr/wallpapers"
      if [ ! -d "$dir" ]; then
        notify-send "Wallpaper directory not found" "Create $dir and add images"
        exit 1
      fi

      selected=$(find -L "$dir" -maxdepth 1 -type f -printf '%f\n' | sort \
        | rofi -dmenu -i -p "Select wallpaper" || true)
      [ -n "$selected" ] || exit 0

      awww img "$dir/$selected" --transition-type fade
      notify-send -i "$dir/$selected" "Wallpaper changed" "$selected"
    '';
  };

  windowSwitcher = pkgs.writeShellApplication {
    name = "hypr-window-switcher";
    runtimeInputs = with pkgs; [ rofi jq libnotify ];
    text = ''
      # "address<TAB>workspace: class — title"; the address (hidden from the
      # visible text by rofi's -display-columns) is what we focus, so titles
      # with ":" or regex characters work.
      windows=$(hyprctl clients -j \
        | jq -r '.[] | "\(.address)\t\(.workspace.id): \(.class) — \(.title)"')
      if [ -z "$windows" ]; then
        notify-send "No windows found"
        exit 0
      fi

      selected=$(printf '%s\n' "$windows" \
        | rofi -dmenu -i -p "Switch to window" -display-columns 2 -display-column-separator '\t' || true)
      [ -n "$selected" ] || exit 0

      hyprctl dispatch "hl.dsp.focus({ window = \"address:''${selected%%$'\t'*}\" })"
    '';
  };
in
{
  # Tell Electron / Chromium apps to use Wayland (Ozone). Wayland-only;
  # belongs to the Hyprland module so non-Wayland hosts don't carry it.
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  home.packages = [
    rofiCalc
    webSearch
    wallpaperPicker
    windowSwitcher
    pkgs.pavucontrol # waybar volume click
    pkgs.qt6Packages.qt6ct # QT_QPA_PLATFORMTHEME=qt6ct (hypr/modules/env.lua)
  ];

  # Notifications (D-Bus activated), polkit prompts (user service, started
  # by graphical-session.target under UWSM) and the screen locker.
  services.dunst.enable = true;
  services.hyprpolkitagent.enable = true;
  programs.hyprlock = {
    enable = true;
    settings = {
      general.hide_cursor = true;
      background = [{ path = "screenshot"; blur_passes = 3; blur_size = 7; }];
      input-field = [{
        size = "300, 50";
        position = "0, -80";
        halign = "center";
        valign = "center";
        outline_thickness = 2;
        placeholder_text = "Contraseña…";
      }];
    };
  };

  xdg.configFile = {
    "hypr/hyprland.lua".source = ./hypr/hyprland.lua;
    "hypr/modules" = {
      source = ./hypr/modules;
      recursive = true;
    };
    "hypr/wallpapers" = {
      source = ./hypr/wallpapers;
      recursive = true;
    };
  };
}
