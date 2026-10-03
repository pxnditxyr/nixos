-- Hyprland Lua config (migrated from hyprland.conf; hyprlang removed in 0.57).
-- Docs: https://wiki.hypr.land/Configuring/Start/


------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "warp-terminal"
local fileManager = "yazi"
local menu        = "rofi -show drun"
-- local menu2    = "vicinae toggle"
local googleSearch = "~/.config/hypr/scripts/rofi-google-search.sh"
local calculator   = "~/.config/hypr/scripts/rofi-calc.sh"

-- Brave Nightly and private Brave Nightly
local browser        = "brave-browser-nightly"
local privateBrowser = "brave-browser-nightly --incognito"
local screenshot     = [[bash -c 'grim -g "$(slurp)" - | swappy -f -']]


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    -- UWSM scope; root cause (portal/graphical-session) fixed, no respawn loop needed.
    hl.exec_cmd("uwsm app -- waybar")
    hl.exec_cmd("vicinae server")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("sleep 1 && awww img ~/.config/hypr/wallpapers/flow-abstract.jpg --transition-type fade")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "20")
hl.env("HYPRCURSOR_SIZE", "20")

hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 8,

        border_size = 2,

        col = {
            active_border   = { colors = { "rgba(00a8e8ee)", "rgba(00ffaaee)" }, angle = 45 },
            inactive_border = "rgba(4a4a4aaa)",
        },

        resize_on_border = false,
        allow_tearing    = false,

        layout = "dwindle",
    },

    decoration = {
        rounding = 10,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 8,
            render_power = 3,
            color        = "rgba(0f0f0fee)",
            offset       = "2 2",
        },

        blur = {
            enabled           = true,
            size              = 5,
            passes            = 2,
            vibrancy          = 0.2,
            new_optimizations = true,
            ignore_opacity    = false,
            xray              = false,
            contrast          = 0.9,
            brightness        = 1.0,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Curves
hl.curve("smoothOut", { type = "bezier", points = { {0.36, 0},    {0.66, -0.56} } })
hl.curve("smoothIn",  { type = "bezier", points = { {0.25, 1},    {0.5, 1}      } })
hl.curve("overshot",  { type = "bezier", points = { {0.05, 0.9},  {0.1, 1.05}   } })
hl.curve("linear",    { type = "bezier", points = { {0, 0},       {1, 1}        } })

-- Animations
hl.animation({ leaf = "global",           enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "windows",          enabled = true, speed = 4, bezier = "overshot",  style = "slide" })
hl.animation({ leaf = "windowsIn",        enabled = true, speed = 4, bezier = "overshot",  style = "slide" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 3, bezier = "smoothOut", style = "slide" })
hl.animation({ leaf = "windowsMove",      enabled = true, speed = 4, bezier = "overshot",  style = "slide" })
hl.animation({ leaf = "border",           enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade",             enabled = true, speed = 3, bezier = "smoothIn" })
hl.animation({ leaf = "fadeDim",          enabled = true, speed = 3, bezier = "smoothIn" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 4, bezier = "overshot",  style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "overshot",  style = "slidevert" })

hl.config({
    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = true,

        vrr = 0, -- 1 or 2 for G-Sync/FreeSync monitors

        mouse_move_enables_dpms = true,
        key_press_enables_dpms  = true,

        animate_manual_resizes       = false,
        animate_mouse_windowdragging = false,

        disable_autoreload = false,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "dvorak",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        repeat_rate  = 25,
        repeat_delay = 400,

        touchpad = {
            natural_scroll       = false,
            disable_while_typing = true,
            tap_to_click          = true,
            drag_lock            = true,
        },
    },
})

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + Return",          hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + W",               hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + M",       hl.dsp.exit())
hl.bind(mainMod .. " + E",               hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B",               hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + SHIFT + B",       hl.dsp.exec_cmd(privateBrowser))
hl.bind(mainMod .. " + V",               hl.dsp.window.float({ action = "toggle" }))
hl.bind("ALT + space",                   hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + space",           hl.dsp.exec_cmd(googleSearch))
hl.bind(mainMod .. " + C",               hl.dsp.exec_cmd(calculator))
hl.bind(mainMod .. " + P",               hl.dsp.window.pseudo())
hl.bind(mainMod .. " + S",               hl.dsp.exec_cmd(screenshot))

-- Maximize window
hl.bind(mainMod .. " + Tab",             hl.dsp.window.fullscreen())

-- Move focus (vim keys)
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Move windows (vim keys)
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

-- Switch workspaces / move active window to a workspace with mainMod (+ SHIFT) + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + D",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia keys for volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),    { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
