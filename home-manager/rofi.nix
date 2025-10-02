{ pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    plugins = [
      pkgs.rofi-emoji
    ];
  };

  xdg.configFile."rofi/config.rasi".text = ''
    configuration {
      modi: "drun,run,emoji"; /* 'modi' es un alias de 'modes' */
      show-icons: true;
      icon-theme: "Papirus";
      drun-display-format: "{name}";
      cache-dir: "/home/pxndxs/.cache/rofi";
    }

    /*******************************************************************************
     * THEME CONFIG
     *******************************************************************************/
    * {
        font:   "Montserrat 14";

        bg0:    #242424E1;
        bg1:    #7E7E7E80;
        bg2:    #551999E6; /* Purple bar highlight  */

        fg0:    #DEDEDE;
        fg1:    #FFFFFF;
        fg2:    #DEDEDE80;

        background-color:   transparent;
        text-color:         @fg0;
        margin:     0;
        padding:    0;
        spacing:    0;
    }

    window {
        background-color:   @bg0;
        location:           center;
        width:              840;
        border-radius:      8;
    }

    inputbar {
        font:       "Montserrat 16";
        padding:    12px;
        spacing:    12px;
        children:   [ icon-search, entry ];
    }

    icon-search {
        expand:     false;
        filename:   "search";
        size:       28px;
    }

    icon-search, entry, element-icon, element-text {
        vertical-align: 0.5;
    }

    entry {
        font:   inherit;
        placeholder:         "Search";
        placeholder-color:   @fg2;
    }

    listview {
        lines:          10;
        columns:        2;
        fixed-height:   false;
        border:         1px 0 0;
        border-color:   @bg1;
    }

    element {
        padding:            8px 16px;
        spacing:            16px;
        background-color:   transparent;
    }

    element selected normal, element selected active {
        background-color:   @bg2;
        text-color:         @fg1;
    }

    element-icon {
        size:   2em;
    }

    element-text {
        text-color: inherit;
    }
  '';
}
