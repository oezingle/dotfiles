
local awful = require("awful")
local wibox = require("wibox")

local LuaX = require("lib.LuaX")
local Renderer = LuaX.Renderer
local create_element = LuaX.create_element
local GearsWorkLoop = require("lib.LuaX.util.WorkLoop.Gears")
local WiboxElement = require("lib.LuaX.util.NativeElement.WiboxElement")

local Taskbar = require("src.awesome.ui.taskbar.Taskbar")

---@param s Awesome.Screen
local function taskbar_for_screen (s)
    if not s.taskbar then
        ---@diagnostic disable-next-line:inject-field
        s.taskbar = awful.wibar {
            position = "top",
            screen = s
        }
    end

    s.taskbar.widget = wibox.widget {
        layout = wibox.container.margin
    }

    local element = create_element(Taskbar, {})

    local root = WiboxElement.get_root(s.taskbar.widget)

    local renderer = Renderer(GearsWorkLoop)

    renderer:render(element, root)
end

return taskbar_for_screen