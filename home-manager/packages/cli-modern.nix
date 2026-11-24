{ pkgs, config, ... }: {
  # bat, eza, zoxide and fzf come from programs.* in ../shell-integrations.nix.
  home.packages = with pkgs; [
    fd
    ripgrep
    tldr
    dust
    btop
    procs
    sd
    yazi
  ];

  # Module rather than package so NH_FLAKE points at this repo.
  programs.nh = {
    enable = true;
    flake = "${config.home.homeDirectory}/.config/nixos";
  };
}
