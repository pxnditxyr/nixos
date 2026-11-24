# 🐼 NeoCats — Pxndxs' own Neovim distribution ❄️
# The neocats flake may not build for every system (e.g. aarch64-darwin): skip it there.
{ inputs, pkgs, lib, ... }:
let
  neocatsForSystem = inputs.neocats.packages.${pkgs.stdenv.hostPlatform.system} or null;
in {
  home.packages = lib.optionals (neocatsForSystem != null && neocatsForSystem ? default) [
    neocatsForSystem.default
  ];
}
