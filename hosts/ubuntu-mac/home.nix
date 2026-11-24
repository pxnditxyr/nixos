# Ubuntu X11 (GNOME Flashback, WhiteSur look kept outside Nix): CLI only.
# No rofi.nix: it would clobber the hand-tuned ~/.config/rofi/whitesur.rasi.
#   home-manager switch --flake ~/.config/nixos#pxndxs@ubuntu-mac -b backup
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../home-manager/cli-base.nix
    ../../home-manager/packages/core-linux.nix
    ../../home-manager/packages/cli-modern-linux.nix
  ];

  home = {
    username = "pxndxs";
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
