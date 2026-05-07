# Ubuntu/X11/macOS-themed Home Manager profile
# ─────────────────────────────────────────────
# Curated subset of the canonical NixOS Home Manager config. Targets a
# non-NixOS Ubuntu 26.04 session running GNOME Flashback (Metacity) on X11
# with a WhiteSur / macOS-style aesthetic layer maintained outside Nix.
#
# What's intentionally excluded versus the canonical profile:
#
#   GUI applications (apt provides equivalents, no need to duplicate):
#     • packages/gui.nix   — warp-terminal, mangohud
#     • chromium.nix       — apt provides Brave Nightly
#     • kitty.nix          — apt-installed Warp covers terminal needs
#     • obs.nix            — install OBS via apt if/when needed
#
#   Wayland-only / X11-incompatible:
#     • hyprland.nix       — Wayland compositor (host is X11)
#     • waybar.nix         — Hyprland status bar (gnome-panel owns the bar)
#
#   Conflicts with manual config:
#     • rofi.nix           — would clobber ~/.config/rofi/whitesur.rasi
#                             (the WhiteSur Spotlight setup is hand-tuned)
#
# Apply with:
#   home-manager switch --flake $HOME/.config/nixos#pxndxs@ubuntu-mac -b backup
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Curated package subset (no GUI apps)
    ../../home-manager/packages/core.nix
    ../../home-manager/packages/cli-modern.nix
    ../../home-manager/packages/dev.nix

    # Shell hooks (zoxide / fzf / bat / eza — binary + init together)
    ../../home-manager/shell-integrations.nix

    # CLI/TUI modules
    ../../home-manager/direnv.nix
    ../../home-manager/fonts.nix
    ../../home-manager/git.nix
    ../../home-manager/jq.nix
    ../../home-manager/neocats.nix
    ../../home-manager/python.nix
    ../../home-manager/zsh.nix
  ];

  nixpkgs = {
    overlays = [];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "pxndxs";
    homeDirectory = "/home/pxndxs";
    # Keep in lock-step with the canonical profile.
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
