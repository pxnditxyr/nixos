# Pxndxs Neovim distribution (custom flake). The upstream flake may not
# publish a build for every system the parent flake targets — fall back to
# `null` and skip the install rather than failing evaluation on systems
# (e.g. aarch64-darwin) where the upstream output is absent.
{ inputs, pkgs, lib, ... }:
let
  neocatsForSystem = inputs.neocats.packages.${pkgs.stdenv.hostPlatform.system} or null;
in {
  home.packages = lib.optionals (neocatsForSystem != null && neocatsForSystem ? default) [
    neocatsForSystem.default
  ];
}
