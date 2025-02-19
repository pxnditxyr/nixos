{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.neocats.packages.${ pkgs.system }.default
  ];
}
