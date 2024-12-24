
---@class LGI.Gdk.Window 
---@field set_cursor fun(self: self, cursor: LGI.Gdk.Cursor)

---@class LGI.Gdk.Cursor
---@field new_from_name fun(display: LGI.Gdk.Display, name: XCursor | string)

---@class LGI.Gdk.Display
---@field get_default fun(): LGI.Gdk.Display

---@class LGI.Gdk
---@field Window LGI.Gdk.Window
---@field Display LGI.Gdk.Display
---@field Cursor LGI.Gdk.Cursor
local Gdk = lgi.require("Gdk", "3.0")

return Gdk