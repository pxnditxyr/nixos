# packages/core.nix — foundational shell utilities every host needs.
# Network tools, archive tools, build essentials. Strictly OS-pure: anything
# that only builds (or only makes sense) on Linux lives in core-linux.nix.
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
    gnumake42
  ];
}
