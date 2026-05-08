# SSH client config — multi-account routing.
# Identity files referenced by path; private keys NEVER tracked in Nix.
# Generate with `ssh-keygen` (see README), then upload .pub to each provider.
{ ... }: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        forwardAgent = false;
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };

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
