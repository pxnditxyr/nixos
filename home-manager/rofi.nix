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
      modi: "drun,run,emoji";
      show-icons: true;
      icon-theme: "Papirus";
      drun-display-format: "{name}";
      cache-dir: "/home/pxndxs/.cache/rofi";
      display-drun: " ";
      display-run: "🐼 ";
      display-emoji: " ";
    }

    * {
        font:   "CaskaydiaCove Nerd Font 13";

        /* Colores de fondo - Más oscuro para mejor contraste */
        bg0:    #1a1a1aF0;
        bg1:    #404040;
        bg2:    #7B3FF2;
        bg3:    #2a2a2a;

        fg0:    #E8E8E8;
        fg1:    #FFFFFF;
        fg2:    #A0A0A0;

        accent: #9D6EFF;
        urgent: #FF6B6B;

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
        border-radius:      10;
        border:             2px;
        border-color:       @accent;
    }

    inputbar {
        font:       "CaskaydiaCove Nerd Font 15";
        padding:    14px;
        spacing:    12px;
        children:   [ prompt, entry ];
        background-color:   @bg3;
        border-radius:      8px;
        margin:             8px;
    }

    prompt {
        enabled:    true;
        font:       "CaskaydiaCove Nerd Font 18";
        text-color: @accent;
        content:    " ";
    }

    prompt, entry, element-icon, element-text {
        vertical-align: 0.5;
    }

    entry {
        font:   inherit;
        placeholder:         "Search";
        placeholder-color:   @fg2;
        text-color:          @fg1;
    }

    listview {
        lines:          10;
        columns:        2;
        fixed-height:   false;
        border:         2px 0 0;
        border-color:   @bg1;
        padding:        4px;
    }

    element {
        padding:            10px 16px;
        spacing:            16px;
        background-color:   transparent;
        border-radius:      6px;
    }

    element normal.normal {
        background-color:   transparent;
        text-color:         @fg0;
    }

    element normal.active {
        background-color:   transparent;
        text-color:         @accent;
    }

    element selected.normal {
        background-color:   @bg2;
        text-color:         @fg1;
    }

    element selected.active {
        background-color:   @bg2;
        text-color:         @fg1;
    }

    element alternate.normal {
        background-color:   transparent;
        text-color:         @fg0;
    }

    element-icon {
        size:           2em;
        background-color: transparent;
    }

    element-text {
        text-color:     inherit;
        background-color: transparent;
    }

    element urgent {
        text-color: @urgent;
    }
  '';
}
