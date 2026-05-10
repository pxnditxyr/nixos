{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zstd,
  alsa-lib,
  curl,
  fontconfig,
  libglvnd,
  libxkbcommon,
  vulkan-loader,
  wayland,
  xdg-utils,
  libxi,
  libxcursor,
  libx11,
  libxcb,
  xz,
  zlib,
  makeWrapper,
  waylandSupport ? false,
}:

let
  pname = "warp-terminal";
  versions = lib.importJSON ./versions.json;
  passthru.updateScript = ./update.sh;

  linuxArch =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      "x86_64"
    else if stdenv.hostPlatform.system == "aarch64-linux" then
      "aarch64"
    else
      throw "warp-terminal: unsupported platform ${stdenv.hostPlatform.system}";

  versionKey = "linux_${linuxArch}";
in
stdenv.mkDerivation (finalAttrs: {
  inherit pname passthru;
  inherit (versions.${versionKey}) version;

  src = fetchurl {
    inherit (versions.${versionKey}) hash;
    url = "https://releases.warp.dev/stable/v${finalAttrs.version}/warp-terminal-v${finalAttrs.version}-1-${linuxArch}.pkg.tar.zst";
  };

  sourceRoot = ".";

  postPatch = ''
    substituteInPlace usr/bin/warp-terminal \
      --replace-fail /opt/ $out/opt/
  '';

  nativeBuildInputs = [
    autoPatchelfHook
    zstd
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    curl
    fontconfig
    (lib.getLib stdenv.cc.cc)
    zlib
    xz
  ];

  runtimeDependencies = [
    libglvnd
    libxkbcommon
    stdenv.cc.libc
    vulkan-loader
    xdg-utils
    libx11
    libxcb
    libxcursor
    libxi
  ] ++ lib.optionals waylandSupport [ wayland ];

  installPhase =
    ''
      runHook preInstall

      mkdir $out
      cp -r opt usr/* $out
    ''
    + lib.optionalString waylandSupport ''
      wrapProgram $out/bin/warp-terminal --set WARP_ENABLE_WAYLAND 1
    ''
    + ''
      runHook postInstall
    '';

  postFixup = ''
    # Keep font discovery working in bundled binary.
    patchelf \
      --add-needed libfontconfig.so.1 \
      $out/opt/warpdotdev/warp-terminal/warp
  '';

  meta = {
    description = "Rust-based terminal";
    homepage = "https://www.warp.dev";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "warp-terminal";
  };
})
