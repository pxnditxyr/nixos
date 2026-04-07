{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.neocats.packages.${ pkgs.stdenv.hostPlatform.system }.default
  ];
}
