{ pkgs, ... }: {
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    victor-mono
    (nerdfonts.override { fonts = [ "JetBrainsMono" "CascadiaMono" "CascadiaCode" "NerdFontsSymbolsOnly" ]; })
    noto-fonts-emoji
    powerline-symbols
  ];
}
