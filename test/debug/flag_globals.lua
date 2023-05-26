
local test = require("lib.test")

local flag_globals = require("src.debug.flag_globals")

local envhacks = require("src.agnostic.version.envhacks")

-- TODO i need these to be actual tests

test.suite("flag_globals", 
    test.test(function ()
        local env = flag_globals.get_env()

        local function test_function ()
            awesome = nil

            print("Hello World!") 

            if awesome then
                print("OMG awesome sauce!")
            end
        end

        envhacks.setfenv(test_function, env)

        test_function()
    end, "env"),
    test.test(function ()
        local require = flag_globals.require

        local fs = require("src.util.fs")

        print(fs.directories.cache)
    end, "require")
)
