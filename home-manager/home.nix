# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./chromium.nix
    ./direnv.nix
    ./fonts.nix
    ./git.nix
    ./hyprland.nix
    ./jq.nix
    ./kitty.nix
    ./neocats.nix
    ./obs.nix
    ./waybar.nix
    ./zsh.nix
    ./python.nix
    ./rofi.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "pxndxs";
    homeDirectory = "/home/pxndxs";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [
    # Core utilities
    wget
    curl
    zip
    unzip
    unrar
    xclip
    clang_multi
    gnumake42

    # Modern CLI replacements (Rust-based, fast and feature-rich)
    bat          # Better cat with syntax highlighting
    eza          # Better ls with colors, icons, git integration (already installed)
    fd           # Better find - simple, fast, user-friendly
    ripgrep      # Better grep - respects .gitignore, super fast
    zoxide       # Better cd - learns your habits (use 'z' command)
    tldr         # Simplified man pages with practical examples
    dust         # Better du - disk usage analyzer with tree view
    btop         # Better top/htop - beautiful system monitor
    procs        # Better ps - modern process viewer
    sd           # Better sed - simpler find & replace

    # Node.js ecosystem
    # nodejs_22
    nodePackages.pnpm
    bun
    fnm

    # File managers and tools
    yazi         # Terminal file manager

    # Development tools
    deno
    mangohud

    # Rust tools (commented, uncomment if needed)
    # cargo
    # rust
    # rustc

    # Other tools
    rPackages.rolldown
    python313Packages.pyngrok
    warp-terminal

    # Development tools
    stripe-cli
  ];

  # Enable home-manager and git
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";
}
