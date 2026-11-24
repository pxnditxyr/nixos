{ pkgs, ... }: {
  home.packages = with pkgs; [
    warp-terminal
    mangohud
    karere
  ];
}
