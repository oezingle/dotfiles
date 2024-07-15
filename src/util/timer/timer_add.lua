
local has_gears, gtimer = pcall(require, "gears.timer")

local GLibTimer = require("src.util.timer.GLibTimer")

---@class Awesome.Gears.Timer
---@field start fun(self: self)
---@field stop fun(self: self)
---@field delayed_call fun(callback: function)

log.debug(has_gears and "timer_add: using gears.timer" or "timer_add: using GLibTimer")

--- https://awesomewm.org/doc/api/classes/gears.timer.html#gears.timer
---@param options { timeout: integer, autostart?: boolean, callback: function, single_shot?: boolean }
---@return Awesome.Gears.Timer
local function timer_add (options)
    if has_gears then
        return gtimer(options)
    else
        return GLibTimer(options)
    end
end

return timer_add