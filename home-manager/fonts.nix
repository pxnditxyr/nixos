{ pkgs, lib, platform, ... }: {
  # fontconfig is a Linux/X11 concept. On darwin, HM installs fonts by
  # symlinking into ~/Library/Fonts and macOS picks them up natively, so the
  # fontconfig path is unnecessary. Gate enable to Linux only.
  fonts.fontconfig.enable = lib.mkDefault platform.isLinux;

  home.packages = with pkgs; [
    victor-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.caskaydia-mono
    nerd-fonts.symbols-only
    noto-fonts-color-emoji
    powerline-symbols
  ];
}
