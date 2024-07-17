
require("src.amenities.init")
local timer_add = require("src.util.timer.timer_add")

local MainLoop = require("src.util.MainLoop")
local hot_reload = require("src.util.hot_reload")

local loop = MainLoop()

timer_add({
    callback = hot_reload.poll,
    timeout = 1,
    autostart = true
})

hot_reload.register()

local add = require("spec.helper.add")

hot_reload.on_change(function ()
    print(add(1, 2))
end)

loop:run()