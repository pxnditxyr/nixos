# Shared nixpkgs policy for all home-manager profiles (via cli-base.nix).
# HM re-imports nixpkgs with this config, so allowUnfree is enough; the old
# allowUnfreePredicate workaround (HM #2942) was fixed in HM 23.11 (#4304).
{ ... }: {
  nixpkgs.config.allowUnfree = true;
}
