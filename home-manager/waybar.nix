{
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
          "wireplumber"
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
          rewrite = {
            "(.*) - Brave" = "🦁 - $1";
            "^v\\s.*" = " Neovim";
            "^~(.*)" = "  ~$1";
          };
          separate-outputs = true;
        };

        network = {
          interval = 1;
          interface = "enp5s0";
          format-ethernet = "  {bandwidthTotalBytes:>3}  ";
          format-wifi = "  {bandwidthTotalBytes:>3}  ";
          tooltip-format-wifi = "{ipaddr} ({signalStrength}%) ";
          tooltip-format = "{ifname} via {gwaddr} ";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "Disconnected 󰀦";
          format-alt = "{ifname} = {ipaddr}/{cidr}";
        };

        "custom/separator" = {
          format = "{icon}";
          format-icons = "";
          tooltip = false;
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
          format = "  {:%a %b %d  %I:%M %p}"; # %b %d %Y  --Date formatting
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format-alt = "{:%Y-%m-%d %H:%M:%S  }";
        };

        actions = {
          on-click-right = "mode";
          on-click-forward = "tz_up";
          on-click-backward = "tz_down";
          on-scroll-up = "shift_up";
          on-scroll-down = "shift_down";
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
      background: #1e1e2e;
      border-radius: 10px;
      border-width: 2px;
      border-style: solid;
      border-color: #11111b;
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
    #custom-separator,
    #backlight {
      background: #1e1e2e;
      padding: 5px 20px;
      margin: 3px 0px;
      margin-top: 10px;
      border: 1px solid #181825;
      border-radius: 10px;
    }

    #tray {
      border-radius: 10px;
      margin-right: 5px;
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
      margin-left: 60px;
      margin-right: 60px;
    }

    #clock {
      color: #fab387;
      border-radius: 10px 10px 10px 10px;
      margin-left: 5px;
      margin-right: 10px;
      border-right: 0px;
    }

    #network
    {
      color: #f9e2af;
      border-left: 0px;
      border-right: 0px;
    }


    #cpu {
      color: #f38ba8;
      border-radius: 10px 0px 0px 10px;
      border-right: 0px;
      margin-left: 10px;
    }

    #pulseaudio.microphone {
      color: #cba6f7;
      margin-right: 0px;
      border-radius: 0 10px 10px 0;
    }

    #memory {
      color: #a6e3a1;
      border-radius: 0 10px 10px 0;
      border-left: 0px;
    }

    #wireplumber {
      color: #f5c2e7;
      border-left: 0px;
      border-right: 0px;
      border-radius: 10px 0 0 10px;
      margin-right: 10px;
    }
    '';
  };
}
