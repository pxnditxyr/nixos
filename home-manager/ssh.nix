# Keys are referenced by path only; never track private keys here.
{ ... }: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    includes = [ "~/.ssh/config.local" ];

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
