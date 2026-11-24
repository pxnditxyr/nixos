# OS-agnostic CLI base shared by every profile; Linux/GUI bits are added per host.
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
    ./ssh.nix
    ./jq.nix
    ./neocats.nix
    ./neopanda.nix
    ./python.nix
    ./zsh.nix
  ];
}
