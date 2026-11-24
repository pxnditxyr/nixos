{
  description = "Pxndxs Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # master to match nixos-unstable.
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 🐼 NeoCats — Pxndxs' own Neovim distribution ❄️
    # No nixpkgs.follows: its nixfmt-classic formatter is gone from current nixpkgs.
    neocats.url = "github:pxnditxyr/neocats";

    # 🐼 neopanda — my Neovim config, packaged and ready to `npd` ❄️
    neopanda.url = "github:pxnditxyr/neopanda";
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
      default = overlay; # pkgs.warp-terminal, newer than nixpkgs
    };

    # Linux-only; empty on darwin so `nix flake check` skips them.
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

    formatter = forAllSystems (system: (pkgsFor system).nixfmt);

    devShells = forAllSystems (system: let
      pkgs = pkgsFor system;
    in {
      default = pkgs.mkShellNoCC {
        packages = with pkgs; [ nixd nixfmt statix deadnix ];
      };
    });

    # `nix flake check` builds every home-manager profile of this system.
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

    nixosConfigurations = {
      pxndxs = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [./nixos/configuration.nix];
      };
    };

    homeConfigurations = {
      "pxndxs@pxndxs" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs;};
        modules = [./home-manager/home.nix];
      };

      "pxndxs@ubuntu-mac" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs;};
        modules = [./hosts/ubuntu-mac/home.nix];
      };

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
