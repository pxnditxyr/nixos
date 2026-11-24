-- https://wiki.hypr.land/Configuring/Basics/Variables/#input
-- Session keyboard source of truth; services.xserver only affects SDDM.

hl.config({
    input = {
        kb_layout  = "us,us",
        kb_variant = "dvorak,",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0,

        repeat_rate  = 25,  -- per second
        repeat_delay = 400, -- ms

        touchpad = {
            natural_scroll        = false,
            disable_while_typing  = true,
            ["tap-to-click"]      = true,
            drag_lock             = 1,
        },
    },
})
