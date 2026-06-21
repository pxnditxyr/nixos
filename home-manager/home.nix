# Canonical NixOS Home Manager profile (Hyprland / Wayland desktop).
# Per-platform values (homeDirectory, the `platform` arg) come from
# ./platform.nix; per-bucket package lists come from ./packages.nix.
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./nixpkgs-config.nix
    ./platform.nix
    ./packages.nix
    ./shell-integrations.nix
    ./brave-nightly.nix
    ./direnv.nix
    ./fonts.nix
    ./git.nix
    ./hyprland.nix
    ./jq.nix
    ./kitty.nix
    ./neocats.nix
    ./obs.nix
    ./waybar.nix
    ./zsh.nix
    ./python.nix
    ./rofi.nix
  ];

  # NixOS canonical: apply warp-terminal overlay in addition to shared
  # nixpkgs.config (allowUnfree) from ./nixpkgs-config.nix above.
  nixpkgs.overlays = [
    inputs.self.overlays.default
  ];

  home = {
    username = "pxndxs";
    # homeDirectory derived in ./platform.nix
  };

  # User-package list lives in ./packages.nix so it is shared by every host
  # (see imports above). Add packages there, not here.

  # Enable home-manager and git
  programs.home-manager.enable = true;
  services.ssh-agent.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.sessionPath = [
    "$HOME/.local/bin"
  ];


  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";
}
