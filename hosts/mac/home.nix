# macOS, CLI only (GUI apps come from Homebrew casks). Username comes from flake.nix.
#   nix run home-manager/master -- switch --flake ~/.config/nixos#<username>@mac -b backup
{
  inputs,
  lib,
  config,
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../home-manager/cli-base.nix
  ];

  home = {
    inherit username;
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
