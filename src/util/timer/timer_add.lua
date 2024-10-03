
local has_gears, gtimer = pcall(require, "gears.timer")

local GLibTimer = require("src.util.timer.GLibTimer")

---@class Awesome.Gears.Timer
---@field start fun(self: self)
---@field stop fun(self: self)
---@field delayed_call fun(callback: function)
---@field started boolean

log.debug(string.format("timer_add using %s", has_gears and "gears.timer" or "GLibTimer" ))

---@class Zingle.Awesome.timer_add.Options 
---@field timeout integer
---@field autostart boolean?
---@field callback function
---@field single_shot boolean?

---@alias Zingle.Timer Awesome.Gears.Timer | Zingle.GLibTimer

--- https://awesomewm.org/doc/api/classes/gears.timer.html#gears.timer
---@param options Zingle.Awesome.timer_add.Options
---@return Awesome.Gears.Timer
local function timer_add (options)
    if has_gears then
        return gtimer(options)
    else
        return GLibTimer(options)
    end
end

return timer_add