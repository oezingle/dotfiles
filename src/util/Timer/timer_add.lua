
local Timer = require("src.util.Timer.Timer")

-- TODO FIXME maybe get rid of this file? timer class does what we need.

---@class Awesome.Gears.Timer
---@field start fun(self: self)
---@field stop fun(self: self)
---@field delayed_call fun(callback: function)
---@field started boolean

---@class Zingle.Awesome.timer_add.Options 
---@field timeout integer
---@field autostart boolean?
---@field callback function
---@field single_shot boolean?

---@alias Zingle.Timer Awesome.Gears.Timer | Zingle.GLibTimer

--- https://awesomewm.org/doc/api/classes/gears.timer.html#gears.timer
---@param options Zingle.Awesome.timer_add.Options
---@return Zingle.Timer
local function timer_add (options)
    return Timer(options)
end

return timer_add