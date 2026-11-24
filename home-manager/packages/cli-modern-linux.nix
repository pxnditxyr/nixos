{ pkgs, ... }: {
  home.packages = with pkgs; [
    playerctl
    qalculate-qt
  ];
}
