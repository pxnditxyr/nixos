# packages/core.nix — foundational shell utilities every host needs.
# Network tools, archive tools, build essentials. Strictly OS-pure: anything
# that only builds (or only makes sense) on Linux lives in core-linux.nix.
{ pkgs, ... }: {
  home.packages = with pkgs; [
    wget
    curl
    zip
    unzip
    unrar
    gnumake
  ];
}
