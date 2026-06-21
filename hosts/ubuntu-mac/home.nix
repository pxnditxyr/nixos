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
#     • brave-nightly.nix  — apt provides Brave Nightly
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
    # Shared CLI-only base (nixpkgs-config, platform, OS-pure packages, shell tools).
    # linux siblings are added below because this host is Linux.
    ../../home-manager/cli-base.nix

    # Linux-only package siblings (not included in cli-base; absent on macOS).
    ../../home-manager/packages/core-linux.nix       # xclip, clang_multi
    ../../home-manager/packages/cli-modern-linux.nix # playerctl, qalculate-qt
  ];

  home = {
    username = "pxndxs";
    # homeDirectory derived in ../../home-manager/platform.nix (via cli-base)
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
