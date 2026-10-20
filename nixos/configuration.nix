# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./sddm.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "pxndxs"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/La_Paz";

  # Select internationalisation properties.
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

  # SDDM (themed in ./sddm.nix) → Hyprland via UWSM. The xserver block below
  # only shapes the greeter (keymap, repeat) and loads the NVIDIA driver; the
  # Hyprland session takes its keyboard settings from hypr/modules/input.lua.
  services.displayManager.defaultSession = "hyprland-uwsm";

  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.variant = "dvorak";
    videoDrivers = [ "nvidia" ];
    # Same as the Hyprland session (hypr/modules/input.lua: 400 ms, 25/s).
    autoRepeatDelay = 400;
    autoRepeatInterval = 40;
  };

  services.gnome.gnome-keyring.enable = lib.mkForce false;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      # VA-API on NVIDIA (LIBVA_DRIVER_NAME=nvidia in hypr/modules/env.lua).
      extraPackages = [ pkgs.nvidia-vaapi-driver ];
    };

    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
      open = false;
      modesetting.enable = true;
      # Saves VRAM across suspend; without it Wayland sessions often come
      # back corrupted after resume.
      powerManagement.enable = true;
      nvidiaSettings = true;
    };
  };


  # Configure console keymap
  console.keyMap = "dvorak";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound with pipewire.
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pxndxs = {
    isNormalUser = true;
    description = "Pxndxs";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  # Install firefox.
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

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };

  # Nix daemon: flakes on (still experimental in upstream Nix) and the
  # nix-community binary cache. (Hyprland comes from nixpkgs, so it is
  # already in cache.nixos.org; no hyprland.cachix needed.)
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@wheel" ];
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Store dedup on a timer instead of auto-optimise-store (which hardlinks
  # during every build and slows them down).
  nix.optimise.automatic = true;

  # nh: nixos-rebuild/home-manager wrapper with diffs + nom output.
  # clean replaces nix.gc (the module asserts they are not both enabled):
  # weekly, keep generations newer than 30d and always the last 5.
  programs.nh = {
    enable = true;
    flake = "/home/pxndxs/.config/nixos";
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since 30d --keep 5";
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # wget, curl, zip, unzip, unrar, xclip — provided by HM packages/core*.nix;
    # not duplicated here to keep one owner per package.

    wl-clipboard # system-level Wayland clipboard (needed pre-login / root)

    networkmanagerapplet
    awww
    libnotify
    # waybar — owned by HM programs.waybar (home-manager/waybar.nix); not here.

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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11";

}
