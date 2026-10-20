# packages/cli-modern-linux.nix — modern CLI tools that are Linux-bound.
# playerctl talks to MPRIS via D-Bus (Linux-only). qalculate-qt is the GUI
# calculator (the qalc CLI used by hypr-rofi-calc comes from libqalculate,
# pinned in ../hyprland.nix).
{ pkgs, ... }: {
  home.packages = with pkgs; [
    playerctl    # Media key controls (XF86AudioNext/Prev/Play/Pause) — MPRIS / D-Bus, Linux-only
    qalculate-qt # Qalculate! GUI calculator
  ];
}
