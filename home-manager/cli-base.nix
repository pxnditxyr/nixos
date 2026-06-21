# Shared CLI-only base for mac and ubuntu-mac profiles.
# OS-pure — no Linux-only packages, no GUI, no Wayland/X11.
# Both hosts import this; ubuntu-mac additionally imports the *-linux siblings.
#
# To add a cross-platform CLI tool: edit the appropriate package bucket under
# home-manager/packages/ — it will propagate here automatically.
{ ... }: {
  imports = [
    ./nixpkgs-config.nix
    ./platform.nix
    ./packages/core.nix
    ./packages/cli-modern.nix
    ./packages/dev.nix
    ./shell-integrations.nix
    ./direnv.nix
    ./fonts.nix
    ./git.nix
    ./jq.nix
    ./neocats.nix
    ./python.nix
    ./zsh.nix
  ];
}
