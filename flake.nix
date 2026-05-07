{
  description = "Pxndxs Configuration";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager — pinned to release branch matching home.stateVersion
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
  in {
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
