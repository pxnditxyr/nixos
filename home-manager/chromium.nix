{ pkgs, config, ... }:
{
  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
      "eifflpmocdbdmepbjaopkkhbfmdgijcc" # JSON Viewer Pro
      "fmkadmapgofadopljbjfkapdkoienihi" # React Developer Tools
    ];
  };
}
