
local Gdk = require("src.util.lgi.Gdk")
local GdkX11 = require("src.util.lgi.GdkX11")
local X11Window = GdkX11.X11Window

--- Own a widget as an GdkX11 X11Window - allows set_cursor on it.
---@param widget Awesome.Wibox.Widget
---@return LGI.Gdk.Window
local function gdk_own_widget (widget)
    local window_id = widget.drawin.window

    local display = Gdk.Display.get_default()

    local window = X11Window.foreign_new_for_display(display, window_id)

    assert(window, "Unable to get widget as foriegn window")

    return window
end

return gdk_own_widget