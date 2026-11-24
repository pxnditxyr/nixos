# Provides the `platform` module arg ({ isDarwin, isLinux }) and home.homeDirectory.
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
