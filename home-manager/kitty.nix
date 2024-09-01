{
  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    font = {
      name = "CaskaydiaCove Nerd Font";
      size = 14;
    };
    theme = "Tokyo Night";
    extraConfig = ''
      background_opacity 0.75
      cursor_shape block
      enable_audio_bell no
      close_on_child_death yes
      disable_ligatures never
      window_padding_width 8

      symbol_map U+23FB-U+23FE,U+2665,U+26A1,U+2B58,U+E000-U+E00A,U+E0A0-U+E0A3,U+E0B0-U+E0C8,U+E0CA,U+E0CC-U+E0D2,U+E0D4,U+E200-U+E2A9,U+E300-U+E3E3,U+E5FA-U+E634,U+E700-U+E7C5,U+EA60-U+EBEB,U+F000-U+F2E0,U+F300-U+F32F,U+F400-U+F4A9,U+F500-U+F8FF Symbols Nerd Font Mono

      map ctrl+shift+l next_tab
      map ctrl+shift+h previous_tab
    '';
  };
}
