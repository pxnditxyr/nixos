{ pkgs, ... }:
{
  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
      "eifflpmocdbdmepbjaopkkhbfmdgijcc" # JSON Viewer Pro
      "fmkadmapgofadopljbjfkapdkoienihi" # React Developer Tools
      "bggfcpfjbdkhfhfmkjpbhnkhnpjjeomc" # Material Icons for GitHub

      # Theme
      "ifjdeonnoidfgpmcpjkdabkkpghameip" # Blooming Pink Flowers Theme
    ];
  };
}
