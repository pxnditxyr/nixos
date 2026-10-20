-- Processes started once with the session.
-- https://wiki.hypr.land/Configuring/Basics/Autostart/

local wallpaper = "~/.config/hypr/wallpapers/flow-abstract.jpg"

-- The session runs under UWSM, so graphical-session.target is active and
-- user services (hyprpolkitagent, dunst) start on their own.

hl.on("hyprland.start", function()
    -- UWSM scope: waybar needs the portal, which needs graphical-session.target.
    hl.exec_cmd("uwsm app -- waybar")
    hl.exec_cmd("vicinae server")
    -- Wait for the awww daemon socket instead of a fixed sleep.
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("until awww query >/dev/null 2>&1; do sleep 0.2; done; awww img "
        .. wallpaper .. " --transition-type fade")
end)
