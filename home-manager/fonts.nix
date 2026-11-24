{ pkgs, lib, platform, ... }: {
  # macOS reads fonts from ~/Library/Fonts; fontconfig is Linux-only.
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
