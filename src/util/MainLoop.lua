
local lgi = require("lgi")
local GLib = lgi.GLib

---@class GLib.MainContext

---@class GLib.MainLoop
---@field is_running boolean
---@field quit fun(self: self)
---@field run fun(self: self)
---@field ref fun(self: self)
---@field unref fun(self: self)
---@field get_context fun(self: self): GLib.MainContext
---@operator call:GLib.MainLoop
local MainLoop = GLib.MainLoop

return MainLoop