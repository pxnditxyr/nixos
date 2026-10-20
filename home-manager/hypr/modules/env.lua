-- Environment variables for the session.
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "20")
hl.env("HYPRCURSOR_SIZE", "20")

-- Native Wayland backends, X11 as fallback.
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

-- NVIDIA (proprietary driver): VA-API through nvidia-vaapi-driver and the
-- NVIDIA GLX vendor library, as recommended by the Hyprland NVIDIA page.
-- Hardware cursors: cursor:no_hardware_cursors defaults to auto, so no
-- WLR_NO_HARDWARE_CURSORS needed.
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
