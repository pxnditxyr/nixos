# Linux-only tools go in core-linux.nix.
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
