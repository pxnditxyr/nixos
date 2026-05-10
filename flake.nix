{
  description = "Pxndxs Configuration";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager — tracks master to match nixos-unstable nixpkgs
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    # NeoCats Pxndxs 🐼 my neovim configuration
    neocats.url = "github:pxnditxyr/neocats";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = [ "x86_64-linux" ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
    overlay = import ./overlays/default.nix;
  in {
    overlays = {
      default = overlay;
      warp-terminal = overlay;
    };

    packages = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlay ];
        config.allowUnfree = true;
      };
      bravePkg = pkgs.callPackage ./pkgs/brave-nightly { };
    in {
      "brave-nightly" = bravePkg;
      "warp-terminal" = pkgs.warp-terminal;
      default = bravePkg;
    });

    apps = forAllSystems (system: let
      pkg = self.packages.${system}."brave-nightly";
      app = {
        type = "app";
        program = "${pkg}/bin/brave-browser-nightly";
      };
    in {
      "brave-nightly" = app;
      default = app;
    });

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      pxndxs = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        # > Our main nixos configuration file <
        modules = [./nixos/configuration.nix];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      # Canonical NixOS profile (Hyprland/Wayland desktop)
      "pxndxs@pxndxs" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
        # > Our main home-manager configuration file <
        modules = [./home-manager/home.nix];
      };

      # Ubuntu/X11/macOS-themed layer — runs the same module ecosystem
      # MINUS the Wayland-only modules (hyprland, waybar) and rofi
      # (kept outside Nix to preserve the WhiteSur Spotlight setup).
      # Apply: home-manager switch --flake .#pxndxs@ubuntu-mac
      "pxndxs@ubuntu-mac" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [./hosts/ubuntu-mac/home.nix];
      };
    };
  };
}
