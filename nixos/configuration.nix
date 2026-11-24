{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./sddm.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "pxndxs";
  # networking.wireless.enable = true;

  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking.networkmanager.enable = true;

  time.timeZone = "America/La_Paz";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_BO.UTF-8";
    LC_IDENTIFICATION = "es_BO.UTF-8";
    LC_MEASUREMENT = "es_BO.UTF-8";
    LC_MONETARY = "es_BO.UTF-8";
    LC_NAME = "es_BO.UTF-8";
    LC_NUMERIC = "es_BO.UTF-8";
    LC_PAPER = "es_BO.UTF-8";
    LC_TELEPHONE = "es_BO.UTF-8";
    LC_TIME = "es_BO.UTF-8";
  };

  services.displayManager.defaultSession = "hyprland-uwsm";

  # Only shapes the SDDM greeter and loads the NVIDIA driver; the Hyprland
  # session takes its keyboard settings from hypr/modules/input.lua.
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.variant = "dvorak";
    videoDrivers = [ "nvidia" ];
    autoRepeatDelay = 400;
    autoRepeatInterval = 40; # 25/s, same as hypr/modules/input.lua
  };

  services.gnome.gnome-keyring.enable = lib.mkForce false;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = [ pkgs.nvidia-vaapi-driver ]; # with LIBVA_DRIVER_NAME in env.lua
    };

    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
      open = false;
      modesetting.enable = true;
      # Without it, Wayland sessions often come back corrupted after resume.
      powerManagement.enable = true;
      nvidiaSettings = true;
    };
  };

  console.keyMap = "dvorak";

  # services.printing.enable = true;

  services.pulseaudio.enable = false;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    #media-session.enable = true;
  };

  # services.xserver.libinput.enable = true;

  users.users.pxndxs = {
    isNormalUser = true;
    description = "Pxndxs";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  programs.firefox.enable = true;
  programs.zsh.enable = true;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    libatomic_ops
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@wheel" ];
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Timer instead of auto-optimise-store, which slows down every build.
  nix.optimise.automatic = true;

  # nh.clean replaces nix.gc (the module refuses both at once).
  programs.nh = {
    enable = true;
    flake = "/home/pxndxs/.config/nixos";
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since 30d --keep 5";
    };
  };

  # CLI tools (wget, curl, zip, xclip, waybar…) are owned by home-manager.
  environment.systemPackages = with pkgs; [
    wl-clipboard # system-level: needed before login and as root

    networkmanagerapplet
    awww
    libnotify

    grim
    swappy
    slurp

    anydesk
    # rustdesk

    vlc

    android-studio
    vicinae

    zenity
    openssl
  ];

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  # programs.hyprland already adds xdg-desktop-portal-hyprland.
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  virtualisation.docker.enable = true;
  # virtualisation.virtualbox.host.enable = true;
  # virtualisation.virtualbox.host.enableExtensionPack = true;

  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # services.openssh.enable = true;

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;

  # Release of the first install; do not bump on upgrades.
  system.stateVersion = "25.11";
}
