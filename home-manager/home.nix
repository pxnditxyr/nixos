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

  nixpkgs = {
    overlays = [
      inputs.self.overlays.default
    ];
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

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

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";
}
