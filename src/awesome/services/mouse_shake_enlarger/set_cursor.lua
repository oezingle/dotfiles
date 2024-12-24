
local Gdk = lgi.require("Gdk", "3.0")

-- TODO does work but only for root window - not in widgets
-- https://stackoverflow.com/questions/44453139/how-to-hide-mouse-pointer-in-gtk-c
-- https://stackoverflow.com/questions/9353114/how-do-i-get-a-list-of-all-windows-on-my-gnome2-desktop-using-pygtk

---@param cursor XCursor | string
---@param window LGI.Gdk.Window?
local function set_cursor (cursor, window)
    local window = window or Gdk.get_default_root_window()
    
    local display = Gdk.Display.get_default()
    local cursor = Gdk.Cursor.new_from_name(display, cursor)

    window:set_cursor(cursor)
end

return set_cursor