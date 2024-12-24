
local Gtk = require("src.util.lgi.Gtk")
local Settings = Gtk.Settings

local settings = Settings.get_default()

local function get_cursor_size()
    return settings["gtk-cursor-theme-size"]
end

return get_cursor_size