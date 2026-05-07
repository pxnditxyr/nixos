# SSH client config — multi-account routing.
# Identity files referenced by path; private keys NEVER tracked in Nix.
# Generate with `ssh-keygen` (see README), then upload .pub to each provider.
{ ... }: {
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";

    matchBlocks = {
      "github.com" = {
        user = "git";
        identityFile = "~/.ssh/id_ed25519_personal";
        identitiesOnly = true;
      };

      "gitlab.com" = {
        user = "git";
        identityFile = "~/.ssh/id_ed25519_work";
        identitiesOnly = true;
      };
    };
  };
}
