# macOS Home Manager profile (Apple Silicon).
# ────────────────────────────────────────────
# Strict headless / terminal-only setup. CLI utilities are managed natively
# by Nix; GUI applications are intentionally absent (install via Homebrew
# casks or the App Store, outside this flake).
#
# What is intentionally EXCLUDED versus the canonical NixOS profile:
#
#   GUI applications (CLI-only mandate):
#     • packages/gui.nix   — warp-terminal, mangohud (Linux GUI)
#     • brave-nightly.nix  — custom .deb repackage, x86_64-linux only
#     • chromium.nix       — programs.chromium is Linux-bound; browser is a cask
#     • kitty.nix          — GUI terminal; use Terminal.app / Warp / Ghostty cask
#     • obs.nix            — install via Homebrew cask if needed
#
#   Wayland / X11 desktop stack (no compositor on macOS):
#     • hyprland.nix       — Wayland compositor
#     • waybar.nix         — Hyprland status bar
#     • rofi.nix           — X11 launcher
#
#   Linux-only package siblings:
#     • packages/core-linux.nix       — xclip, clang_multi
#     • packages/cli-modern-linux.nix — playerctl, qalculate-qt
#
# User-agnostic base module — identity is injected by the flake via
# extraSpecialArgs.username. One file serves every Mac (work, personal, …);
# each homeConfiguration in flake.nix supplies its own username string and
# platform.nix derives /Users/<username> from config.home.username.
#
# Apply with:
#   home-manager switch --flake $HOME/.config/nixos#<username>@mac -b backup
#
# First-time bootstrap (no `home-manager` binary yet):
#   nix run home-manager/master -- switch \
#     --flake $HOME/.config/nixos#<username>@mac -b backup
{
  inputs,
  lib,
  config,
  pkgs,
  username,
  ...
}: {
  imports = [
    # Platform abstraction (sets homeDirectory to /Users/<username> + exposes `platform`)
    ../../home-manager/platform.nix

    # Curated package subset — pure (OS-agnostic) buckets only.
    ../../home-manager/packages/core.nix
    ../../home-manager/packages/cli-modern.nix
    ../../home-manager/packages/dev.nix

    # Shell hooks (zoxide / fzf / bat / eza — binary + init together)
    ../../home-manager/shell-integrations.nix

    # CLI / TUI modules
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
    inherit username;
    # homeDirectory is derived in ../../home-manager/platform.nix
    # → /Users/${username} on macOS.
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
