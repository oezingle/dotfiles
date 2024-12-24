
local Gdk = lgi.require("Gdk", "3.0")

--[[
local Gtk = require("src.util.lgi.Gtk")
local Settings = Gtk.Settings

local settings = Settings.get_default()
local join = require("src.polyfill.path.join")
local fs = require("src.util.fs")
]]

local function gdk_get_cursor_image ()
    local display = Gdk.Display.get_default()
    local cursor = Gdk.Cursor.new_from_name(display, "default")

    return cursor:get_surface()
end

-- https://www.x.org/releases/X11R7.6/doc/man/man3/Xcursor.3.xhtml
-- XCursor has its own image format. it is basically just bitmap. bruh.
--[[
local function get_cursor_image()
    -- https://stackoverflow.com/questions/77389498/how-can-i-retrieve-mouse-cursor-images-on-ubuntu-in-c-or-c

    -- TODO FIXME allow overwriting this value with something from configuration
    local theme_name = settings["gtk-cursor-theme-name"]
    for _, dir in pairs({
        "~/.icons",
        "~/.local/share/icons",
        "/usr/share/icons"
    }) do
        local possible_dir = join(dir, theme_name)

        log.info(possible_dir)

        if fs.is_dir(possible_dir) then
            local cursor_path = join(possible_dir, "cursors/default")

            log.info("Using cursor from", cursor_path)

            return cursor_path
        end
    end

    log.warn("Using Gdk for cursor image. It will be blurry")

    return gdk_get_cursor_image()
end
]]

return gdk_get_cursor_image
