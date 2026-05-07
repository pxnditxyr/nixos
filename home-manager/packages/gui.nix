# packages/gui.nix — desktop / GUI applications.
# This module is intentionally NOT imported by hosts that already have
# native packaging for these apps (e.g. Ubuntu via apt). It is wired up
# in the canonical NixOS profile only.
{ pkgs, ... }: {
  home.packages = with pkgs; [
    warp-terminal   # AI-augmented terminal (Electron-based GUI)
    mangohud        # In-game performance overlay (GUI/Vulkan layer)
  ];
}
