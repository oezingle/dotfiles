
require("src.amenities.init")

local MainLoop = require("src.util.MainLoop")
local loop = MainLoop()

local inspect = require("lib.inspect.inspect")
local config = require("src.configuration")

config:on_change(function (config)
    log.info(inspect(config.configuration))
end)

loop:run()