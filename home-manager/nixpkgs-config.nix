# Shared nixpkgs policy for all home-manager profiles.
# Imported by cli-base.nix (mac/ubuntu) and by home.nix (NixOS canonical).
# Overlays are NOT set here — they are profile-specific (NixOS uses the
# warp-terminal overlay; mac/ubuntu use none).
{ ... }: {
  nixpkgs.config = {
    allowUnfree = true;
    # Workaround for https://github.com/nix-community/home-manager/issues/2942
    allowUnfreePredicate = _: true;
  };
}
