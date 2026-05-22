# platform.nix — single source of truth for OS-conditional values.
# Exposes `platform = { isDarwin, isLinux }` to every Home Manager module via
# _module.args, and derives home.homeDirectory from the username + host OS so
# per-host profiles do not have to hardcode the path.
{ pkgs, lib, config, ... }: {
  _module.args.platform = {
    isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
    isLinux = pkgs.stdenv.hostPlatform.isLinux;
  };

  home.homeDirectory = lib.mkDefault (
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${config.home.username}"
    else "/home/${config.home.username}"
  );
}
