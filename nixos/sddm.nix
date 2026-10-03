{ pkgs, lib, ... }:

let
  wallpaper = ../home-manager/hypr/wallpapers/flow-abstract.jpg;
  avatar = ./assets/avatar.png;

  cursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
  };

  # Palette shared with rofi/waybar: purple accent on dark glass.
  text = "#F5F5F7";
  accent = "#9D6EFF";
  accentHover = "#C4A7FF";

  sddmTheme = (pkgs.sddm-astronaut.override {
    embeddedTheme = "astronaut";
    themeConfig = {
      ScreenWidth = "1920";
      ScreenHeight = "1080";
      Font = "Inter";
      FontSize = "14";
      RoundCorners = "28";
      HourFormat = "HH:mm";
      DateFormat = "dddd, d MMMM";
      HeaderText = "";

      # Same wallpaper as the desktop -> seamless handoff after login.
      Background = "Backgrounds/glass.jpg";
      CropBackground = "true";
      DimBackground = "0.25";
      DimBackgroundColor = "#0b0b12";

      # Frosted glass card.
      PartialBlur = "true";
      HaveFormBackground = "true";
      FormPosition = "center";
      Blur = "2.0";
      BlurMax = "64";
      FormBackgroundColor = "#1a1a24";
      BackgroundColor = "#1a1a24";

      LoginFieldBackgroundColor = "#26ffffff";
      PasswordFieldBackgroundColor = "#26ffffff";
      LoginFieldTextColor = text;
      PasswordFieldTextColor = text;
      HeaderTextColor = text;
      DateTextColor = text;
      TimeTextColor = text;
      UserIconColor = text;
      PasswordIconColor = text;
      PlaceholderTextColor = "#A0A0B0";
      WarningColor = "#FF6B6B";
      LoginButtonTextColor = "#ffffff";
      LoginButtonBackgroundColor = accent;
      SystemButtonsIconsColor = text;
      SessionButtonTextColor = text;
      VirtualKeyboardButtonTextColor = text;
      DropdownTextColor = text;
      DropdownSelectedBackgroundColor = accent;
      DropdownBackgroundColor = "#1a1a24";
      HighlightTextColor = "#ffffff";
      HighlightBackgroundColor = accent;
      HighlightBorderColor = accent;
      HoverUserIconColor = accentHover;
      HoverPasswordIconColor = accentHover;
      HoverSystemButtonsIconsColor = accentHover;
      HoverSessionButtonTextColor = accentHover;
      HoverVirtualKeyboardButtonTextColor = accentHover;

      # Behavior.
      ForceLastUser = "true";
      PasswordFocus = "true";
      UseRealName = "true";
      HideVirtualKeyboard = "true";
    };
  }).overrideAttrs (old: {
    # Theme resolves Background relative to its own dir -> copy wallpaper in.
    postInstall = (old.postInstall or "") + ''
      chmod u+w $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds
      cp ${wallpaper} $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/glass.jpg
    '';
  });
in
{
  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm; # Qt6, required by sddm-astronaut
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    extraPackages = [ sddmTheme ];
    settings = {
      Theme = {
        CursorTheme = cursor.name;
        CursorSize = cursor.size;
      };
      Users.RememberLastUser = true;
      General.RememberLastSession = true;
    };
  };

  environment.systemPackages = [ sddmTheme cursor.package ];

  fonts.packages = [ pkgs.inter ];

  # SDDM can't read ~/.face.icon (home is 0700); AccountsService icon dir works.
  systemd.tmpfiles.rules = lib.optionals (builtins.pathExists avatar) [
    "L+ /var/lib/AccountsService/icons/pxndxs - - - - ${avatar}"
  ];
}
