
local GLib = lgi.GLib

---@class GLib.MainContext
---@field push_thread_default fun(self: self) make this context the thread default
---@field pop_thread_default fun(self: self) remove this context as the thread default

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