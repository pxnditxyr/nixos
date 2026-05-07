# Aggregator — pulls in every package category.
# Imported by the canonical NixOS profile (home-manager/home.nix). Hosts that
# want a curated subset (e.g. hosts/ubuntu-mac/home.nix) should import the
# individual files under ./packages/ directly and skip this aggregator.
{ ... }: {
  imports = [
    ./packages/core.nix
    ./packages/cli-modern.nix
    ./packages/dev.nix
    ./packages/gui.nix
  ];
}
