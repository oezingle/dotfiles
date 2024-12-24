require("src.amenities.init")

local Virtualize = require("src.util.Virtualize")

Virtualize()
    :set_input(function()
        local argparse = require("lib.argparse")

        local parser = argparse()

        parser:argument("something", "fake argument")

        parser:parse({})

        print("hello world!")
    end)
    :set_env({
        os = {
            exit = function (code)
                error(string.format("Exit with code %d", code))
            end
        },
    })
    :preload_module("lib.argparse")
    :get_module()