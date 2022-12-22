local test = require("lib.test")

local Promise = require("src.util.Promise")

local print = require("src.agnostic.print")

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

    test.awesome_only_test(function()
        Promise(function(res)
            require("awful.spawn").easy_async("which awesome", res)
        end)
            :after(function(awesome_path)
                assert(awesome_path and type(awesome_path) == "string")
            end)
            :catch(function (err)
                print("Error in async promise test:", err)
            end)
    end, "Async Promise"),

    test.awesome_only_test(function()
        Promise(function(_, rej)
            require("awful.spawn").easy_async("which awesome", rej)
        end)
            :catch(function(awesome_path)
                assert(awesome_path)
            end)
    end, "Async Promise Rejection"),

    test.awesome_only_test(function()
        Promise.resolve()
            :after(function()
                return Promise(function(res)
                    require("awful.spawn").easy_async("which awesome", res)
                end)
            end)
            -- Check that nested :after works
            :after(function(...)
                return ...
            end)
            :after(function(awesome_path)
                assert(awesome_path and type(awesome_path) == "string")
            end)
            :catch(function (err)
                print("Error in async promise test:", err)
            end)
    end, "Async Promise Nesting"),

    -- TODO is actually broken
    test.awesome_only_test(function()
        Promise.all({
            Promise(function(res)
                require("awful.spawn").easy_async("which awesome", res)
            end),
            Promise(function(res)
                require("awful.spawn").easy_async("which awesome-client", res)
            end),
        })
            :after(function(values)
                assert(values[1][1] == "/usr/bin/awesome\n")
                assert(values[2][1] == "/usr/bin/awesome-client\n")
            end)
            :catch(function (err)
                print("Error in async promise test:", err)
            end)
    end, "Async Promise.all()")
)