# SSH client config — multi-account routing.
# Identity files referenced by path; private keys NEVER tracked in Nix.
# Generate with `ssh-keygen` (see README), then upload .pub to each provider.
{ ... }: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    includes = [ "~/.ssh/config.local" ];

    # Modern HM SSH API: programs.ssh.settings (DAG keyed by Host pattern,
    # capitalized OpenSSH directive names). Replaces the deprecated
    # programs.ssh.matchBlocks. Bools render as yes/no.
    settings."*" = {
      AddKeysToAgent      = "yes";
      ForwardAgent        = false;
      Compression         = false;
      ServerAliveInterval = 0;
      ServerAliveCountMax = 3;
      HashKnownHosts      = false;
      UserKnownHostsFile  = "~/.ssh/known_hosts";
      ControlMaster       = "no";
      ControlPath         = "~/.ssh/master-%r@%n:%p";
      ControlPersist      = "no";
    };
  };
}
