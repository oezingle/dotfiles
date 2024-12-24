local rubato = require("lib.rubato")

--[[
    This class is basically andOrlando/rubato but now it's something that can be globally disabled.
]]

---@class Zingle.Awesome.Animated : Log.BaseFunctions
---
---@operator call:Zingle.Awesome.Animated
local Animated = class("Zingle.Awesome.Animated")

---@alias Zingle.Awesome.Animated.Callback fun(pos: number)

---@class Zingle.Awesome.Animated.Options
---@field subscribed Zingle.Awesome.Animated.Callback
---@field duration number
---@field target number?
--- TODO I don't care to understand rubato's easing functions rn

-- TODO low power mode - disable animations.

Animated.global_enabled = true

---@param options Zingle.Awesome.Animated.Options
function Animated:init(options)
    self:set_subscribed(options.subscribed)

    self.rubato_timer = rubato.timed {
        subscribed = self.subscribed,
        duration = options.duration,
        rate = 30
    }

    self:set_target(options.target or 0)

    self.enabled = true
end

function Animated:set_subscribed(callback)
    self.subscribed = callback

    return self
end

---@param enabled boolean
---@return self
function Animated:set_enabled(enabled)
    self.enabled = enabled

    return self
end

function Animated:enable()
    return self:set_enabled(true)
end

function Animated:disable()
    return self:set_enabled(false)
end

-- TODO returning a promise sounds nice but i think it's basically impossible
function Animated:set_target(target)
    if self.enabled and self.global_enabled then
        self.rubato_timer.target = target
    else
        self.subscribed(target)
    end
end

return Animated
