local Service = require("src.util.Service")
local SmartTimer = require("src.util.Timer.SmartTimer")

---@class Zingle.Awesome.TimerService : Zingle.Awesome.Service
---@field timer Zingle.SmartTimer
---@field on_timer fun(self: self)
local TimerService = Service:extend("Zingle.Awesome.TimerService")

function TimerService:start()
    if not self.timer then
        self.timer = SmartTimer.create({
            timeout = 30,
            callback = function()
                self:on_timer()
            end,
            autostart = false
        })
    end

    self.timer:start()
end

---@param timeout number
function TimerService:set_timeout(timeout)
    self.timer.timeout = timeout

    return self
end

function TimerService:stop()
    if self.timer then
        self.timer:stop()
    end
end

--- needs an overload otherwise TimerService.create returns Service
---@param options Zingle.Awesome.Service.Options
---@return Zingle.Awesome.TimerService
function TimerService.create(options)
    return TimerService(options)
end

return TimerService
