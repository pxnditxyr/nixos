{ pkgs, ... }: {
  home.packages = with pkgs; [
    xclip # zsh copy aliases on X11 (zsh.nix)
    clang_multi
  ];
}
