# Canonical NixOS Home Manager profile (Hyprland / Wayland desktop).
# Shared CLI base (packages, shell, git, ssh, …) comes from ./cli-base.nix,
# the same module the mac / ubuntu-mac profiles use; this file only adds the
# Linux + GUI layer on top.
{ inputs, ... }: {
  imports = [
    ./cli-base.nix

    # Linux-only package buckets
    ./packages/core-linux.nix
    ./packages/cli-modern-linux.nix
    ./packages/gui.nix

    # GUI / Wayland desktop
    ./brave-nightly.nix
    ./hyprland.nix
    ./kitty.nix
    ./obs.nix
    ./rofi.nix
    ./waybar.nix
  ];

  # Local warp-terminal build (pkgs/warp-terminal), ahead of nixpkgs.
  nixpkgs.overlays = [ inputs.self.overlays.default ];

  home.username = "pxndxs";
  # homeDirectory derived in ./platform.nix

  programs.home-manager.enable = true;
  services.ssh-agent.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";
}
