{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        modules-left = ["hyprland/workspaces"];
        modules-center = ["hyprland/window"];
        modules-right = ["pulseaudio" "network" "tray" "clock"];

        "hyprland/window" = {
          rewrite = {
            "(.*) — Mozilla Firefox" = "🌎 $1";
            "(tmux)" = "💻 Term";
          };
          separate-outputs = true;
        };

        network = {
          format-ethernet = "{ipaddr}/{cidr}";
        };

        clock = {
          format = "{:%H:%M}  ";
          format-alt = "{:%A, %B %d, %Y (%R)}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
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

        pulseaudio = {
          format = "{volume}% {icon}";
          format-bluetooth = "{volume}% {icon}";
          format-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" ""];
          };
          scroll-step = 1;
          on-click = "pavucontrol";
          ignored-sinks = ["Easy Effects Sink"];
        };
      };
    };
    style = ''
      * {
        border: none;
      }

      window#waybar {
          font-family: "Victor Mono Bold";
          font-size: 12px;
          background-color: rgba(50, 50, 50, 0.9);
          color: white;
      }

      #workspaces button {
        background-color: #bbccdd;
        color: #333333;
        margin-left: 0.25em;
        margin-right: 0.25em;
        padding: 0 0.5em;
      }

      #clock,
      #tray,
      #pulseaudio,
      #network {
        padding: 0 0.5em 0;
        margin-left: 0.25em;
        margin-right: 0.25em;
        background-color: #bbccdd;
        color: #333333;
        border-radius: 3px;
      }
    '';
  };
}
