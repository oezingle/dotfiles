
local test = require("lib.test")

local JobQueue = require("src.util.JobQueue")
local Promise = require("src.util.Promise")

test.suite("JobQueue",
    test.test(function ()
        local queue = JobQueue()
        
        local res = Promise.await(queue:add(function ()
            return Promise.resolve("Hello World!")
        end))

        assert(res == "Hello World!")
    end, "queue:add return value parity"),
    test.test(function ()
        local queue = JobQueue()

        queue:disable_autostart()

        local res, res2

        queue:add(function ()
            return Promise.resolve("Hello World!")
        end, "a")
            :after(function (a)
                res = a
            end)

        queue:add(function ()
            return Promise.resolve("Goodbye World!")
        end, "a")
            :after(function (b)
                res2 = b
            end)

        Promise.await(queue:start())

        assert(res == res2)
    end, "queue:add identifier parity")
)