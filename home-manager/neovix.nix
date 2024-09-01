{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.neovix.packages.${ pkgs.system }.default
  ];
}
