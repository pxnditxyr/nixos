{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  adwaita-icon-theme,
  gsettings-desktop-schemas,
  gtk3,
  gtk4,
  qt6,
  libx11,
  libxscrnsaver,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxrandr,
  libxrender,
  libxtst,
  libdrm,
  libkrb5,
  libuuid,
  libxkbcommon,
  libxshmfence,
  libgbm,
  nspr,
  nss,
  pango,
  pipewire,
  snappy,
  udev,
  wayland,
  xdg-utils,
  coreutils,
  libxcb,
  zlib,
  dpkg,
  gnused,
  gnugrep,
  xz,
  binutils,

  commandLineArgs ? "",
  pulseSupport ? stdenv.hostPlatform.isLinux,
  libpulseaudio,
  libGL,
  libvaSupport ? stdenv.hostPlatform.isLinux,
  libva,
  enableVideoAcceleration ? libvaSupport,
  vulkanSupport ? false,
  addDriverRunpath,
  enableVulkan ? vulkanSupport,
}:

let
  pname = "brave-browser-nightly";
  version = "1.90.79";

  allArchives = {
    x86_64-linux = {
      url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-browser-nightly_${version}_amd64.deb";
      # Reemplaza si fijas otra versión:
      # nix store prefetch-file <url> --json | jq -r .hash
      hash = "sha256-PIdbxBWQQZ8eVXyOB5VumRfaarAcVpG1Bli68tNxqF8=";
    };
    # GitHub Nightly no publica .deb arm64 de forma consistente.
    # Si aparece en un release futuro, agrega su URL/hash aquí.
  };

  archive =
    if builtins.hasAttr stdenv.system allArchives then
      allArchives.${stdenv.system}
    else
      throw "brave-browser-nightly: unsupported platform ${stdenv.system} for GitHub .deb";

  inherit (lib)
    optional
    optionals
    makeLibraryPath
    makeSearchPathOutput
    makeBinPath
    optionalString
    strings
    escapeShellArg
    ;

  deps = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    gtk4
    libdrm
    libx11
    libGL
    libxkbcommon
    libxscrnsaver
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxshmfence
    libxtst
    libuuid
    libgbm
    nspr
    nss
    pango
    pipewire
    udev
    wayland
    libxcb
    zlib
    snappy
    libkrb5
    qt6.qtbase
  ]
  ++ optional pulseSupport libpulseaudio
  ++ optional libvaSupport libva;

  rpath = makeLibraryPath deps + ":" + makeSearchPathOutput "lib" "lib64" deps;
  binpath = makeBinPath deps;

  enableFeatures =
    optionals enableVideoAcceleration [
      "AcceleratedVideoDecodeLinuxGL"
      "AcceleratedVideoEncoder"
    ]
    ++ optional enableVulkan "Vulkan";

  disableFeatures = [
    "OutdatedBuildDetector"
  ]
  ++ optionals enableVideoAcceleration [ "UseChromeOSDirectVideoDecoder" ];
in
stdenv.mkDerivation {
  inherit pname version;
  src = fetchurl archive;

  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true;
  doInstallCheck = stdenv.hostPlatform.isLinux;

  nativeBuildInputs = [
    # Needed for wrapGAppsHook3 splicing
    (buildPackages.wrapGAppsHook3.override { makeWrapper = buildPackages.makeShellWrapper; })
    dpkg
    gnused
    gnugrep
    xz
    binutils
  ];

  buildInputs = [
    glib
    gsettings-desktop-schemas
    gtk3
    gtk4
    adwaita-icon-theme
  ];

  # Avoid dpkg-deb dependency in host env; extract with ar+tar from the .deb
  unpackPhase = ''
    runHook preUnpack
    mkdir -p source
    cd source
    ar p "$src" data.tar.xz | tar -xJ --no-same-permissions --no-same-owner
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out" "$out/bin"
    cp -R usr/share "$out"
    cp -R opt "$out"

    export BINARYWRAPPER="$out/opt/brave.com/brave-nightly/brave-browser-nightly"
    substituteInPlace "$BINARYWRAPPER" \
      --replace-fail /bin/bash ${stdenv.shell} \
      --replace-fail 'CHROME_WRAPPER' 'WRAPPER'

    ln -sf "$BINARYWRAPPER" "$out/bin/brave-browser-nightly"

    for exe in "$out/opt/brave.com/brave-nightly/"{brave,chrome_crashpad_handler}; do
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${rpath}" \
        "$exe"
    done

    for desktop in \
      "$out/share/applications/brave-browser-nightly.desktop" \
      "$out/share/applications/com.brave.Browser.nightly.desktop"; do
      if [ -f "$desktop" ]; then
        substituteInPlace "$desktop" \
          --replace-fail /usr/bin/brave-browser-nightly "$out/bin/brave-browser-nightly"
      fi
    done

    if [ -f "$out/share/gnome-control-center/default-apps/brave-browser-nightly.xml" ]; then
      substituteInPlace "$out/share/gnome-control-center/default-apps/brave-browser-nightly.xml" \
        --replace-fail /opt/brave.com "$out/opt/brave.com"
    fi

    if [ -f "$out/share/menu/brave-browser-nightly.menu" ]; then
      substituteInPlace "$out/share/menu/brave-browser-nightly.menu" \
        --replace-fail /opt/brave.com "$out/opt/brave.com"
    fi

    substituteInPlace "$out/opt/brave.com/brave-nightly/default-app-block" \
      --replace-fail /opt/brave.com "$out/opt/brave.com"

    for icon in 16 24 32 48 64 128 256; do
      mkdir -p "$out/share/icons/hicolor/''${icon}x''${icon}/apps"
      ln -sf \
        "$out/opt/brave.com/brave-nightly/product_logo_''${icon}_nightly.png" \
        "$out/share/icons/hicolor/''${icon}x''${icon}/apps/brave-browser-nightly.png"
    done

    ln -sf ${xdg-utils}/bin/xdg-settings "$out/opt/brave.com/brave-nightly/xdg-settings"
    ln -sf ${xdg-utils}/bin/xdg-mime "$out/opt/brave.com/brave-nightly/xdg-mime"

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : ${rpath}
      --prefix PATH : ${binpath}
      --suffix PATH : ${
        lib.makeBinPath [
          xdg-utils
          coreutils
        ]
      }
      --set CHROME_WRAPPER ${pname}
      ${optionalString (enableFeatures != [ ]) ''
        --add-flags "--enable-features=${strings.concatStringsSep "," enableFeatures}\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+,WaylandWindowDecorations --enable-wayland-ime=true}}"
      ''}
      ${optionalString (disableFeatures != [ ]) ''
        --add-flags "--disable-features=${strings.concatStringsSep "," disableFeatures}"
      ''}
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto}}"
      ${optionalString vulkanSupport ''
        --prefix XDG_DATA_DIRS : "${addDriverRunpath.driverLink}/share"
      ''}
      --add-flags ${escapeShellArg commandLineArgs}
    )
  '';

  installCheckPhase = ''
    "$out/opt/brave.com/brave-nightly/brave" --version
  '';

  meta = {
    homepage = "https://brave.com/";
    description = "Brave Nightly browser (GitHub release .deb repackaged for Nix)";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.mpl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "brave-browser-nightly";
  };
}
