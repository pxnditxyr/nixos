-- Look and feel, layouts and misc.
-- https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 8,

        border_size = 2,

        -- Soft blue → aqua gradient for contrast.
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
            offset       = { 2, 2 },
        },

        -- Light blur for performance.
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

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = true,

        vrr = 0, -- 1 or 2 with a G-Sync/FreeSync monitor

        mouse_move_enables_dpms = true,
        key_press_enables_dpms  = true,

        -- Snappier manual resize/drag.
        animate_manual_resizes        = false,
        animate_mouse_windowdragging  = false,

        disable_autoreload = false,
    },
})

-- Smooth curves with a soft bounce.
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("smoothOut", { type = "bezier", points = { { 0.36, 0 },   { 0.66, -0.56 } } })
hl.curve("smoothIn",  { type = "bezier", points = { { 0.25, 1 },   { 0.5, 1 } } })
hl.curve("overshot",  { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("linear",    { type = "bezier", points = { { 0, 0 },      { 1, 1 } } })

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
