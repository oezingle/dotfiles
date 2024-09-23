
local GLib = lgi.GLib

---@class GLib.MainContext

---@class LGI.GLib.MainLoop
---@field is_running boolean
---@field quit fun(self: self)
---@field run fun(self: self)
---@field ref fun(self: self)
---@field unref fun(self: self)
---@field get_context fun(self: self): GLib.MainContext
---@operator call:LGI.GLib.MainLoop
local MainLoop = GLib.MainLoop

return MainLoop