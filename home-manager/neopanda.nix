# neopanda 🐼 Neovim config. The package carries the config and its tools; plugins install on the first `npd`.
{ inputs, pkgs, ... }:
{
  home.packages = [ inputs.neopanda.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
