
do
    local timer = require("gears.timer")
    local start, stop = timer.start, timer.stop
    local timers = {}
    function timer:start()
        timers[self] = debug.traceback()
        return start(self)
    end
    function timer:stop()
        timers[self] = nil
        return stop(self)
    end
    timer.start_new(1, function()
        print("Active timers:")
        for timer, traceback in pairs(timers) do
            print(timer, timer.timeout, traceback)
        end
        print("End of timers")
    end)
end