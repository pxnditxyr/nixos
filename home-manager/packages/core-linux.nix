# packages/core-linux.nix — Linux-only foundational utilities.
# Pulled in by hosts that run on Linux. Items here either depend on X11 / a
# Linux-specific build (xclip) or only ship in nixpkgs as a Linux variant
# (clang_multi → multilib clang). Darwin profiles must NOT import this file.
{ pkgs, ... }: {
  home.packages = with pkgs; [
    xclip         # X11 clipboard CLI (sourced by zsh clipboard aliases)
    clang_multi   # Multilib clang — Linux-only variant
  ];
}
