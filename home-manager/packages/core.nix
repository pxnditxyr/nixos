# packages/core.nix — foundational shell utilities every host needs.
# Network tools, archive tools, build essentials, X11 clipboard.
# Also pulls SSH client config (multi-account routing) since SSH is
# foundational; landing here means every host that imports core gets it.
{ pkgs, ... }: {
  imports = [ ../ssh.nix ];

  home.packages = with pkgs; [
    wget
    curl
    zip
    unzip
    unrar
    xclip
    clang_multi
    gnumake42
  ];
}
