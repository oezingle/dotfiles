local timer_add = require("src.util.Timer.timer_add")

---@class Zingle.SmartTimer : Log.BaseFunctions, Zingle.Awesome.timer_add.Options
---@field options Zingle.Awesome.timer_add.Options
---@field timer Zingle.Timer
---@field started boolean
---
---@operator call:Zingle.SmartTimer
local SmartTimer = class("Zingle.SmartTimer", {
})

---@param options Zingle.Awesome.timer_add.Options
function SmartTimer:init(options)
    self.options = options

    self:recreate()
end

---@param options Zingle.Awesome.timer_add.Options
---@return Zingle.SmartTimer
function SmartTimer.create(options)
    return SmartTimer(options)
end

function SmartTimer:recreate()
    local autostart = self.timer and self.timer.started

    if autostart then
        self:stop()
    end

    self.timer = nil

    self.timer = timer_add(self.options)

    if autostart then
        self:start()
    end
end

function SmartTimer:__newindex(k, v)
    if k == "timeout" then
        -- minimize timer recreations
        if self.options.timeout ~= v then
            self.options.timeout = v

            log.debug(string.format("Timer timeout changed to %f", v))

            self:recreate()
        end
    else
        rawset(self, k, v)
    end
end

-- TODO FIXME not my best work
function SmartTimer:__index(k)
    -- TODO does this line need to exist? im pretty sure self is indexed before __index
    local from_self = rawget(self, k)
    if from_self then
        return from_self
    end

    if self.class[k] then
        return self.class[k]
    end


    if k == "started" then
        return self.timer.started
    end

    return self.options[k]
end

function SmartTimer:start()
    self.timer:start()
end

function SmartTimer:stop()
    self.timer:stop()
end

return SmartTimer

--[[
require("src.amenities.init")
SmartTimer = require("src.util.Timer.SmartTimer")
timer = SmartTimer({ callback = function () print('hi') end, timeout = 5 })
]]
