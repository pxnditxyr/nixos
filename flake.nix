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

    # Hyprland comes from nixpkgs (programs.hyprland), no flake input needed.

    # NeoCats Pxndxs 🐼 my neovim configuration. Keeps its own nixpkgs: with
    # `inputs.nixpkgs.follows` its formatter (nixfmt-classic, removed from
    # current nixpkgs) fails to evaluate. Revisit once neocats switches to nixfmt.
    neocats.url = "github:pxnditxyr/neocats";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    systems = [ "x86_64-linux" "aarch64-darwin" ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
    pkgsFor = system: nixpkgs.legacyPackages.${system};
    overlay = import ./overlays/default.nix;
  in {
    overlays = {
      default = overlay; # injects pkgs.warp-terminal (local build, newer than nixpkgs)
    };

    # Custom packages (brave-nightly, warp-terminal) are Linux-only.
    # lib.optionalAttrs keeps the output attrset empty on darwin so
    # `nix flake check` skips them.
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

    # `nix fmt`
    formatter = forAllSystems (system: (pkgsFor system).nixfmt);

    # `nix develop`: Nix LSP + formatter + linters for editing this repo.
    devShells = forAllSystems (system: let
      pkgs = pkgsFor system;
    in {
      default = pkgs.mkShellNoCC {
        packages = with pkgs; [ nixd nixfmt statix deadnix ];
      };
    });

    # `nix flake check` builds every home-manager profile of this system
    # (the NixOS one evaluates via nixosConfigurations).
    checks = forAllSystems (system:
      nixpkgs.lib.mapAttrs' (name: cfg:
        nixpkgs.lib.nameValuePair "home-${builtins.replaceStrings [ "@" ] [ "-" ] name}" cfg.activationPackage)
      (nixpkgs.lib.filterAttrs (_: cfg: cfg.pkgs.stdenv.hostPlatform.system == system)
        self.homeConfigurations));

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
        specialArgs = {inherit inputs;};
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
        extraSpecialArgs = {inherit inputs;};
        # > Our main home-manager configuration file <
        modules = [./home-manager/home.nix];
      };

      # Ubuntu/X11/macOS-themed layer — runs the same module ecosystem
      # MINUS the Wayland-only modules (hyprland, waybar) and rofi
      # (kept outside Nix to preserve the WhiteSur Spotlight setup).
      # Apply: home-manager switch --flake .#pxndxs@ubuntu-mac
      "pxndxs@ubuntu-mac" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs;};
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
          inherit inputs;
          username = "pxndxs";
        };
        modules = [./hosts/mac/home.nix];
      };

      "shipedge@mac" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        extraSpecialArgs = {
          inherit inputs;
          username = "shipedge";
        };
        modules = [./hosts/mac/home.nix];
      };
    };
  };
}
