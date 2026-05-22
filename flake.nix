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

    # Hyprland (Linux-only; referenced only by the NixOS profile)
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
    systems = [ "x86_64-linux" "aarch64-darwin" ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
    overlay = import ./overlays/default.nix;
  in {
    overlays = {
      default = overlay;
      warp-terminal = overlay;
    };

    # Custom packages (brave-nightly, warp-terminal) are Linux-only.
    # lib.optionalAttrs keeps the output attrset empty on darwin systems
    # so `nix flake check` does not try to build them there.
    packages = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlay ];
        config.allowUnfree = true;
      };
    in nixpkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux (let
      bravePkg = pkgs.callPackage ./pkgs/brave-nightly { };
    in {
      "brave-nightly" = bravePkg;
      "warp-terminal" = pkgs.warp-terminal;
      default = bravePkg;
    }));

    apps = forAllSystems (system:
      if self.packages.${system} ? "brave-nightly"
      then let
        pkg = self.packages.${system}."brave-nightly";
        app = {
          type = "app";
          program = "${pkg}/bin/brave-browser-nightly";
        };
      in {
        "brave-nightly" = app;
        default = app;
      }
      else {}
    );

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

      # Headless / terminal-only macOS profiles (Apple Silicon).
      # CLI tooling only — no GUI apps, no Wayland/X11 modules, no Brave.
      # Identity is injected per profile via extraSpecialArgs.username; the
      # shared ./hosts/mac/home.nix module and ./home-manager/platform.nix
      # derive home.username + home.homeDirectory from it.
      # Apply: home-manager switch --flake .#<username>@mac -b backup
      "pxndxs@mac" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        extraSpecialArgs = {
          inherit inputs outputs;
          username = "pxndxs";
        };
        modules = [./hosts/mac/home.nix];
      };

      "shipedge@mac" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        extraSpecialArgs = {
          inherit inputs outputs;
          username = "shipedge";
        };
        modules = [./hosts/mac/home.nix];
      };
    };
  };
}
