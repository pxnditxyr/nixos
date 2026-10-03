{
  # Tell Electron / Chromium apps to use Wayland (Ozone). Wayland-only;
  # belongs to the Hyprland module so non-Wayland hosts don't carry it.
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  xdg.configFile = {
    "hypr/hyprland.lua".source = ./hypr/hyprland.lua;
    "hypr/scripts" = {
      source = ./hypr/scripts;
      recursive = true;
    };
    "hypr/wallpapers" = {
      source = ./hypr/wallpapers;
      recursive = true;
    };
  };
}
