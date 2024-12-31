
local taskbar_for_screen = require("src.awesome.ui.taskbar")
local awful = require("awful")

local console_install_on_focused = require("src.awesome.ui.Console.install_on_focused")

local WiboxElement = require("lib.LuaX.util.NativeElement.WiboxElement")
WiboxElement.add_mod("flexbox", require("src.awesome.widget.mod.flexbox"))

local function init_ui ()
    -- TODO can this be achieved through LuaX?
    awful.screen.connect_for_each_screen(function (s)
        taskbar_for_screen(s)
    end)

    console_install_on_focused()
end

return init_ui