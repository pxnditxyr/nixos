{ pkgs, ... }:
let
  kbLayoutScript = pkgs.writeShellScript "waybar-kb-layout" ''
    set -eu
    variant="$(${pkgs.setxkbmap}/bin/setxkbmap -display "''${DISPLAY:-:0}" -query 2>/dev/null \
      | ${pkgs.gnugrep}/bin/grep -E '^variant:' | ${pkgs.gawk}/bin/awk '{print $2}')"
    case "$variant" in
      dvorak) echo "DV" ;;
      *)      echo "US" ;;
    esac
  '';

  kbToggleScript = pkgs.writeShellScript "waybar-kb-toggle" ''
    set -eu
    variant="$(${pkgs.setxkbmap}/bin/setxkbmap -display "''${DISPLAY:-:0}" -query 2>/dev/null \
      | ${pkgs.gnugrep}/bin/grep -E '^variant:' | ${pkgs.gawk}/bin/awk '{print $2}')"
    if [ "$variant" = "dvorak" ]; then
      ${pkgs.setxkbmap}/bin/setxkbmap -display "''${DISPLAY:-:0}" us
    else
      ${pkgs.setxkbmap}/bin/setxkbmap -display "''${DISPLAY:-:0}" us dvorak
    fi
    ${pkgs.procps}/bin/pkill -RTMIN+10 waybar || true
  '';

  powerMenuScript = pkgs.writeShellScript "waybar-power-menu" ''
    set -eu

    if command -v wlogout >/dev/null 2>&1; then
      exec wlogout
    fi

    if command -v rofi >/dev/null 2>&1; then
      choice="$(printf '%s\n' \
        '⏻ Apagar' \
        ' Reiniciar' \
        '󰌾 Cerrar sesión' \
        '󰤄 Suspender' \
        ' Bloquear' \
        | rofi -dmenu -i -p 'Power')"

      case "$choice" in
        '⏻ Apagar') exec systemctl poweroff ;;
        ' Reiniciar') exec systemctl reboot ;;
        '󰌾 Cerrar sesión')
          if command -v hyprctl >/dev/null 2>&1; then
            exec hyprctl dispatch exit
          fi
          ;;
        '󰤄 Suspender') exec systemctl suspend ;;
        ' Bloquear')
          if command -v hyprlock >/dev/null 2>&1; then
            exec hyprlock
          else
            exec loginctl lock-session
          fi
          ;;
      esac
      exit 0
    fi

    exec systemctl poweroff
  '';
in {
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 0;
        exclusive = true;
        passtrough = false;
        gtk-layer-shell = true;
        spacing = 1;
        reload_style_on_change = true;

        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];

        modules-center = [
          "clock"
        ];

        modules-right = [
          "cpu"
          "custom/separator"
          "memory"
          "custom/separator"
          "network"
          "custom/separator"
          "custom/kblayout"
          "custom/separator"
          "wireplumber"
          "tray"
          "custom/power"
        ];

        "hyprland/workspaces" = {
          persistent-workspaces = {
            "1" = [];
            "2" = [];
            "3" = [];
            "4" = [];
            "5" = [];
            "6" = [];
            "7" = [];
            "8" = [];
            # "9" = [];
          };
          "on-click" = "activate";
          # "active-only" = false;
          # "all-outputs" = true;
          "format" = "{icon}";
          "format-icons" = {
            "1" = "";
            "2" = "";
            "3" = "";
            "4" = "";
            "5" = "";
            "6" = "";
            "7" = "";
            "8" = "󰌠";
            "9" = "󰊢";
          };
        };


        cpu = {
          interval = 1;
          format = "{usage}% ";
          tooltip = false;
          on-click = "hyprctl dispatcher togglespecialworkspace monitor";
        };

        memory = {
          interval = 1;
          format = " {used:0.1f}G/{total:0.1f}";
          max-length = 10;
        };

        "hyprland/window" = {
          icon = true;
          icon-size = 16;
          format = "{}";
          max-length = 120;
          rewrite = {
            "(.*) - Brave" = "$1";
            "^v\\s.*" = "Neovim";
            "^~(.*)" = "~$1";
          };
          separate-outputs = true;
        };

        network = {
          interval = 1;
          format-ethernet = "  {bandwidthTotalBytes:>3}  ";
          format-wifi = "  {bandwidthTotalBytes:>3}  ";
          tooltip-format-wifi = "{ipaddr} ({signalStrength}%) ";
          tooltip-format = "{ifname} via {gwaddr} ";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "Disconnected 󰀦";
          format-alt = "{ifname} = {ipaddr}/{cidr}";
        };



        # clock = {
        #   format = "{:%H:%M}  ";
        #   format-alt = "{:%A, %B %d, %Y (%R)}";
        #   tooltip-format = "<tt><small>{calendar}</small></tt>";
        #   calendar = {
        #     mode = "year";
        #     mode-mon-col = 3;
        #     weeks-pos = "right";
        #     on-scroll = 1;
        #     format = {
        #       months = "<span color='#ffead3'><b>{}</b></span>";
        #       days = "<span color='#ecc6d9'><b>{}</b></span>";
        #       weeks = "<span color='#99ffdd'><b>W{}</b></span>";
        #       weekdays = "<span color='#ffcc66'><b>{}</b></span>";
        #       today = "<span color='#ff6699'><b><u>{}</u></b></span>";
        #     };
        #   };

        clock = {
          interval = 60;
          format = "  {:%a %b %d  %I:%M %p}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format-alt = "{:%Y-%m-%d %H:%M:%S  }";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
          actions = {
            on-click-right = "mode";
            on-click-forward = "tz_up";
            on-click-backward = "tz_down";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };
        wireplumber = {
          format = "{volume}% {icon}";
          format-muted = "{volume}% 󰖁";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" ""];
          };
          format-bluetooth = "{volume}% {icon}";

          scroll-step = 1;
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-click-right = "pavucontrol";
          on-scroll-up = "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 1%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-";
        };
        "custom/separator" = {
          format = "•";
          tooltip = false;
        };

        "custom/kblayout" = {
          format = "{}";
          exec = "${kbLayoutScript}";
          interval = 2;
          signal = 10;
          tooltip = true;
          tooltip-format = "Click: toggle US ↔ Dvorak";
          on-click = "${kbToggleScript}";
        };

        "custom/power" = {
          format = "⏻";
          tooltip = true;
          tooltip-format = "Power menu";
          on-click = "${powerMenuScript}";
        };

        tray = {
          icon-size = 21;
          spacing = 10;
        };
      };
    };
    style = ''
    * {
      border: none;
      border-radius: 0;
      font-family: CaskaydiaCove Nerd Font, monospace;
      font-weight: bold;
      font-size: 18px;
      min-height: 0;
    }

    window#waybar {
      background: rgba(21, 18, 27, 0);
      color: #cdd6f4;
    }

    tooltip {
      background: rgba(30, 30, 46, 0.95);
      border-radius: 10px;
      border-width: 2px;
      border-style: solid;
      border-color: #cba6f7;
      box-shadow: 0px 0px 10px rgba(0,0,0,0.5);
    }

    #workspaces button {
      font-size: 20px;
      padding: 5px;
      color: #313244;
      margin-right: 5px;
    }

    #workspaces button.active {
      color: #a6adc8;
    }

    #workspaces button.focused {
      color: #a6adc8;
      background: #eba0ac;
      border-radius: 10px;
    }

    #workspaces button.urgent {
      color: #11111b;
      background: #a6e3a1;
      border-radius: 10px;
    }

    #workspaces button:hover {
      background: #11111b;
      color: #cdd6f4;
      border-radius: 10px;
    }

    #window,
    #clock,
    #network,
    #workspaces,
    #tray,
    #memory,
    #cpu,
    #wireplumber,
    #custom-kblayout,
    #custom-power,
    #backlight {
      background: #1e1e2e;
      padding: 5px 16px;
      margin: 3px 0px;
      margin-top: 10px;
      border: 1px solid #181825;
      border-radius: 10px;
      transition: all 0.3s ease;
    }

    #clock:hover,
    #network:hover,
    #tray:hover,
    #memory:hover,
    #cpu:hover,
    #wireplumber:hover,
    #custom-kblayout:hover,
    #custom-power:hover,
    #backlight:hover {
      background: #313244;
      border: 1px solid #cba6f7;
    }

    #tray {
      border-radius: 10px;
      margin-right: 0px;
    }

    #custom-separator {
      color: #6c7086;
      background: transparent;
      border: none;
      padding: 0 6px;
      margin: 0;
      margin-top: 10px;
      min-width: 0;
    }

    #workspaces {
      background: #1e1e2e;
      border-radius: 10px;
      margin-left: 10px;
      padding-right: 0px;
      padding-left: 5px;
    }

    #window {
      border-radius: 10px;
      margin-left: 14px;
      margin-right: 14px;
    }

    #custom-power {
      color: #f38ba8;
      margin-right: 10px;
      min-width: 24px;
      font-size: 19px;
    }

    #clock {
      color: #fab387;
      margin-right: 10px;
    }

    #network {
      color: #f9e2af;
    }

    #cpu {
      color: #f38ba8;
      margin-left: 10px;
    }

    #pulseaudio.microphone {
      color: #cba6f7;
    }

    #memory {
      color: #a6e3a1;
    }

    #wireplumber {
      color: #f5c2e7;
      margin-right: 10px;
    }

    #custom-kblayout {
      color: #94e2d5;
    }

    #network.disconnected {
      background: #f38ba8;
      color: #11111b;
      animation-name: blink;
      animation-duration: 0.5s;
      animation-timing-function: linear;
      animation-iteration-count: infinite;
      animation-direction: alternate;
    }

    @keyframes blink {
      to {
        background-color: #f38ba8;
        color: #11111b;
      }
    }
    '';
  };
}
