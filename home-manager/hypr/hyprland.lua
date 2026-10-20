-- Hyprland config (Lua, Hyprland 0.55+; hyprland.conf is no longer read
-- since 0.56). Wiki: https://wiki.hypr.land/Configuring/Start/
--
-- Split by topic; require() resolves from ~/.config/hypr, so
-- require("modules.binds") loads ~/.config/hypr/modules/binds.lua.

require("modules.env")
require("modules.monitors")
require("modules.look")
require("modules.input")
require("modules.binds")
require("modules.rules")
require("modules.autostart")
