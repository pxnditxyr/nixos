# Built from this HM's own pkgs (unfree already allowed in nixpkgs-config.nix)
# instead of the flake's `packages` output, which is a second nixpkgs import.
{ pkgs, ... }: {
  home.packages = [ (pkgs.callPackage ../pkgs/brave-nightly { }) ];
}
