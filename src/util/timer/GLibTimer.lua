
local GLib = lgi.GLib

---@class Zingle.GLibTimer : Log.BaseFunctions
---@operator call:Zingle.GLibTimer
local GLibTimer = class("Zingle.GLibTimer")

function GLibTimer:init (opts)
    -- if not awesome then
    --     self.mainloop = MainLoop(nil, false)
    -- end

    local cb = opts.callback

    --self.timeout = round(opts.timeout)    
    self.timeout = opts.timeout    
    
    self.started = false

    local single_shot = opts.single_shot

    GLib.timeout_add_seconds(
        GLib.PRIORITY_DEFAULT,
        self.timeout,
        function ()
            if self.started then
                cb()
            end

            return not single_shot
        end
    )

    if opts.autostart then
        self:start()
    end
end

function GLibTimer:start()
    self.started = true
end

function GLibTimer:stop ()
    self.started = false
end

---@param cb function
function GLibTimer.delayed_call(cb)
    GLib.idle_add(GLib.PRIORITY_DEFAULT, function ()
        cb()
        
        return false
    end)
end

--[[
--- Unused more complex implementation
---@param cb function
---@param interval integer
function GLibTimer:add (cb, interval)
    -- https://docs.gtk.org/glib/func.timeout_source_new_seconds.html
    local source = GLib.timeout_source_new_seconds(interval)
    -- https://docs.gtk.org/glib/method.Source.set_callback.html
    source:set_callback(cb)
    
    local context = self.mainloop:get_context()
    source:attach(context)
end
]]

return GLibTimer