
local test = require("lib.test")
local json = require("lib.json")

local list_sinks = require("src.util.pulseaudio.list_sinks")

test.suite("list_sinks",
    test.test(function ()
        list_sinks(function (sinks)
            for i, sink in ipairs(sinks) do
                print(i, json.encode(sink))
            end
        end)
    end)
)