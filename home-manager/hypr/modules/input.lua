-- Keyboard, mouse, touchpad.
-- https://wiki.hypr.land/Configuring/Basics/Variables/#input
--
-- Two layouts: Dvorak (default, index 0) and US QWERTY. Switch by clicking
-- the waybar language module (`hyprctl switchxkblayout all next`).
-- Repeat: this is the single source of truth for the session; the
-- services.xserver values in nixos/configuration.nix only affect SDDM.

hl.config({
    input = {
        kb_layout  = "us,us",
        kb_variant = "dvorak,",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        repeat_rate  = 25,  -- repeats per second
        repeat_delay = 400, -- ms before repeating starts

        touchpad = {
            natural_scroll        = false,
            disable_while_typing  = true,
            ["tap-to-click"]      = true,
            drag_lock             = 1,
        },
    },
})
