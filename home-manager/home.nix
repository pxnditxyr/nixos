{ inputs, ... }: {
  imports = [
    ./cli-base.nix

    ./packages/core-linux.nix
    ./packages/cli-modern-linux.nix
    ./packages/gui.nix

    ./brave-nightly.nix
    ./hyprland.nix
    ./kitty.nix
    ./obs.nix
    ./rofi.nix
    ./waybar.nix
  ];

  # Local warp-terminal build, newer than nixpkgs.
  nixpkgs.overlays = [ inputs.self.overlays.default ];

  home.username = "pxndxs";

  programs.home-manager.enable = true;
  services.ssh-agent.enable = true;

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "25.11";
}
