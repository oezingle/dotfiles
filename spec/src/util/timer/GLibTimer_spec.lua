
local GLibTimer = require("src.util.timer.GLibTimer")
local MainLoop = require("src.util.MainLoop")

describe("GLibTimer", function ()
    it("runs for a given amount of time", function ()
        local calls = 0

        local loop = MainLoop()

        local start = os.time()

        GLibTimer({
            timeout = 0.1,
            callback = function ()
                if calls >= 1 then
                    loop:quit()
                end

                calls = calls + 1
            end,
            autostart = true
        })

        loop:run()

        local stop = os.time()

        assert.near(1, stop - start, 1)
    end)
end)