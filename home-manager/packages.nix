# Aggregator — pulls in every package category for Linux hosts.
# Imported by the canonical NixOS profile (home-manager/home.nix). Hosts that
# want a curated subset (e.g. hosts/ubuntu-mac/home.nix, hosts/mac/home.nix)
# should import the individual files under ./packages/ directly and skip this
# aggregator. The -linux.nix siblings are included here because the NixOS
# profile is Linux by definition.
{ ... }: {
  imports = [
    ./packages/core.nix
    ./packages/core-linux.nix
    ./packages/cli-modern.nix
    ./packages/cli-modern-linux.nix
    ./packages/dev.nix
    ./packages/gui.nix
  ];
}
