{ pkgs, ... }: {
  fonts.fontconfig.enable = true;

  # home.packages = with pkgs; [
  #   victor-mono
  #   (nerdfonts.override { fonts = [ "JetBrainsMono" "CascadiaMono" "CascadiaCode" "NerdFontsSymbolsOnly" ]; })
  #   noto-fonts-emoji
  #   powerline-symbols
  # ];
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
