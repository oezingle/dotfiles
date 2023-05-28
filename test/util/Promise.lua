local test = require("lib.test")

local Promise = require("src.util.Promise")

local MainLoop = require("src.util.lgi.MainLoop")

local print = require("src.agnostic.print")

local function get_time_ms()
    return tonumber(assert(assert(io.popen 'date +%s%3N'):read 'a'))
end

local loop = MainLoop()

-- TODO this is still a synchronous function dumbass
---@param time? number in ms to sleep. default 1000ms
---@return Promise
local function promise_sleep(time)
    time = time or 1000

    local target = get_time_ms() + time

    return Promise(function(res)
        loop:idle_add(function()
            if get_time_ms() >= target then
                res()

                return false
            end

            return true
        end)
    end)
end

loop:idle_add(function(loop)
    test.suite("Promise",
        test.test(function()
            Promise(function(res)
                res("Hello?")
            end)
                :after(function(input)
                    return input:gsub("?", "!")
                end)
                :after(function(input)
                    assert(input)
                end)
        end, "Promise()"),

        test.test(function()
            Promise.resolve()
                :after(function()
                    return "Promise test 2"
                end)
                :after(function(input)
                    assert(input)
                end)
        end, "Promise.resolve()"),
        test.test(function()
            Promise.resolve("Hello")
                :after(function(input)
                    assert(input)
                end)
        end, "Promise.resolve(<value>)"),

        test.test(function()
            Promise.reject("Testing!")
                :after(function()
                    print("I shouldn't fire!")

                    assert(false)
                end)
                :catch(function(value)
                    assert(value == "Testing!")
                end)

            -- TODO fix this behavior
            --[[
            :catch(function()
                print("I shouldn't fire!")

                -- assert(false)
            end)
            ]]
        end, "Promise.reject()"),

        test.test(function()
            Promise.resolve()
                :after(function()
                    error("Hello catch()")
                end)
                :after(function()
                    -- Promise:chain has no-op functions by default, so :after silently includes a :catch handler
                    print("I'm a rejection condiut test!")
                end)
                :catch(function(message)
                    assert(message)
                end)
        end, "Promise:after() throws an error"),

        test.test(function()
            Promise.resolve()
                :after(function()
                    return Promise.resolve("Hola")
                end)
                :after(function(input)
                    assert(type(input) == "string")
                end)
        end, "Promise nesting"),

        test.test(function()
            Promise.all({
                Promise.resolve("Hello!"),
                Promise.resolve("Hola!"),
            })
                :after(function(values)
                    assert(values[1][1] == "Hello!")
                    assert(values[2][1] == "Hola!")
                end)
        end, "Promise.all()"),

        test.test(function()
            Promise.await(promise_sleep(1)
                :catch(function(err)
                    print("Error in async promise test:", err)
                end))
        end, "Async Promise"),

        -- This assumes the whole lua program takes more than 1 ms. Bad work but whatever
        test.test(function()
            Promise(function(_, rej)
                promise_sleep(1):after(function() rej("some_argument") end)
            end)
                :catch(function(error_argument)
                    assert(error_argument)
                end)
        end, "Async Promise Rejection"),

        test.test(function()
            Promise.await(Promise.resolve()
                :after(function()
                    return promise_sleep(1):after(function() return "Hello World!" end)
                end)
                -- Check that nested :after works
                :after(function(...)
                    return ...
                end)
                :after(function(ret)
                    assert(ret == "Hello World!")
                end)
                :catch(function(err)
                    print("Error in async promise test:", err)
                end))
        end, "Async Promise Nesting"),

        test.test(function()
            Promise.await(Promise.all({
                    promise_sleep(1):after(function() return true end),
                    promise_sleep(1):after(function() return false end)
                })
                :after(function(values)
                    assert(values[1][1] == true)
                    assert(values[2][1] == false)
                end)
                :catch(function(err)
                    print("Error in async promise test:", err)
                end))
        end, "Async Promise.all()")
    )

    loop:quit()
end)

loop:run()
