# packages/cli-modern-linux.nix — modern CLI tools that are Linux-bound.
# playerctl talks to MPRIS via D-Bus (Linux-only). qalculate-qt is consumed by
# the Hyprland rofi calculator script and pulls Qt; not needed on macOS where
# this profile is headless / terminal-only.
{ pkgs, ... }: {
  home.packages = with pkgs; [
    playerctl    # Media key controls (XF86AudioNext/Prev/Play/Pause) — MPRIS / D-Bus, Linux-only
    qalculate-qt # Provides qalc CLI used by Hyprland rofi calculator script
  ];
}
