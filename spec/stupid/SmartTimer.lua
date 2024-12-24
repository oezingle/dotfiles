
require("src.amenities.init")

local SmartTimer = require("src.util.Timer.SmartTimer")

local MainLoop = require("src.util.lgi.MainLoop")

local loop = MainLoop()

---@type Zingle.SmartTimer
local timer

timer = SmartTimer.create({    
    callback = function ()
        timer.timeout = timer.timeout - 0.1

        print("hi")

        if timer.timeout <= 0 then
            timer:stop()

            loop:quit()
        end
    end,
    timeout = 1,
    autostart = true
})

loop:run()