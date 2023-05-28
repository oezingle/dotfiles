local class = require("lib.30log")

local lgi = require("lgi")
local GLib = lgi.GLib

---@class MainLoop : Log.BaseFunctions
---@operator call:MainLoop
local MainLoop = class("MainLoop", {})

function MainLoop:init()
    self.mainloop = GLib.MainLoop(nil, false)
end

---@protected
function MainLoop:_get_context()
    return self.mainloop:get_context()
end

--- Get the GLib mainloop
function MainLoop:native()
    return self.mainloop
end

---@param callback fun(loop: MainLoop): boolean? a function that returns true so long as it is running
---@param priority unknown|number?
function MainLoop:idle_add(callback, priority)
    priority = priority ~= nil and priority or GLib.PRIORITY_DEFAULT

    self:_get_context():push_thread_default()

    GLib.idle_add(priority, function()
        local ok, res = pcall(callback, self)

        if ok then
            return res
        else
            print(debug.traceback(res))

            self:quit()

            error(res)

            return false
        end
    end)

    self:_get_context():pop_thread_default()
end

function MainLoop:run()
    self.mainloop:run()
end

function MainLoop:quit()
    self.mainloop:quit()
end

return MainLoop
