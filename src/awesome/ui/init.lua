
local taskbar_for_screen = require("src.awesome.ui.taskbar")
local awful = require("awful")

local function init_ui ()
    -- TODO can this be achieved through LuaX?
    awful.screen.connect_for_each_screen(function (s)
        taskbar_for_screen(s)
    end)
end

return init_ui