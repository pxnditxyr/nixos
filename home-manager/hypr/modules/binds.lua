-- Keybindings. https://wiki.hypr.land/Configuring/Basics/Binds/
-- hypr-* commands are Nix-built scripts (home-manager/hyprland.nix).

local terminal       = "warp-terminal"
local fileManager    = "kitty -e yazi" -- TUI, needs a terminal window
local menu           = "rofi -show drun"
local webSearch      = "hypr-web-search"
local calculator     = "hypr-rofi-calc"
local browser        = "brave-browser-nightly"
local privateBrowser = "brave-browser-nightly --incognito"
local screenshot     = [[grim -g "$(slurp)" - | swappy -f -]]

local mainMod = "SUPER"
local function key(mods) return mainMod .. " + " .. mods end

-- Apps
hl.bind(key("Return"),    hl.dsp.exec_cmd(terminal))
hl.bind(key("E"),         hl.dsp.exec_cmd(fileManager))
hl.bind(key("B"),         hl.dsp.exec_cmd(browser))
hl.bind(key("SHIFT + B"), hl.dsp.exec_cmd(privateBrowser))
hl.bind("ALT + Space",    hl.dsp.exec_cmd(menu))
hl.bind(key("Space"),     hl.dsp.exec_cmd(webSearch))
hl.bind(key("C"),         hl.dsp.exec_cmd(calculator))
hl.bind(key("S"),         hl.dsp.exec_cmd(screenshot))

-- Windows
hl.bind(key("W"),         hl.dsp.window.close())
hl.bind(key("SHIFT + M"), hl.dsp.exit())
hl.bind(key("V"),         hl.dsp.window.float({ action = "toggle" }))
hl.bind(key("P"),         hl.dsp.window.pseudo()) -- dwindle
hl.bind(key("Tab"),       hl.dsp.window.fullscreen())

-- Focus / move with vim keys
local dirs = { h = "left", l = "right", k = "up", j = "down" }
for k, dir in pairs(dirs) do
    hl.bind(key(k),                    hl.dsp.focus({ direction = dir }))
    hl.bind(key("SHIFT + " .. k:upper()), hl.dsp.window.move({ direction = dir }))
end

-- Workspaces: SUPER+[0-9] switch, SUPER+SHIFT+[0-9] move window
for i = 1, 10 do
    local n = i % 10 -- 10 maps to key 0
    hl.bind(key(n),              hl.dsp.focus({ workspace = i }))
    hl.bind(key("SHIFT + " .. n), hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad
hl.bind(key("D"),         hl.dsp.workspace.toggle_special("magic"))
hl.bind(key("SHIFT + D"), hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces
hl.bind(key("mouse_down"), hl.dsp.focus({ workspace = "e+1" }))
hl.bind(key("mouse_up"),   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize with SUPER + LMB/RMB drag
hl.bind(key("mouse:272"), hl.dsp.window.drag(),   { mouse = true })
hl.bind(key("mouse:273"), hl.dsp.window.resize(), { mouse = true })

-- Volume (works on the lock screen, repeats while held)
local media = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), media)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      media)
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     media)
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   media)

-- Media (playerctl)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
