
-- TODO autogen LGI types from Glib docs somehow?

---@class CLGI
---@field GLib LGI.GLib
---@field require fun(library: string, version?: string)

---@alias LGI.GLib.LoopCallback fun(): (boolean?)

---@class LGI.GLib
---@field idle_add fun(priority: integer, callback: LGI.GLib.LoopCallback) Add a function to the default context's mainloop
---@field PRIORITY_DEFAULT 0
---@field MainLoop LGI.GLib.MainLoop
---@field Variant LGI.GLib.GVariant
---@field timeout_add fun(priority: integer, milliseconds: integer, fun: LGI.GLib.LoopCallback)
---@field timeout_add_seconds fun(priority: integer, seconds: integer, fun: LGI.GLib.LoopCallback)
---@alias LGI CLGI | table

---@type LGI
---@diagnostic disable-next-line:lowercase-global
lgi = require("lgi")
