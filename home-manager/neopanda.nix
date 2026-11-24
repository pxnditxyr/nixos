# 🐼 neopanda — Pxndxs' Neovim config, tools included ❄️
# Plugins install on the first `npd`.
{ inputs, pkgs, ... }:
{
  home.packages = [ inputs.neopanda.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
