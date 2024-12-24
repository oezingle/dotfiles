
local LuaX = require("lib.LuaX")
local awful = require("awful")
local Renderer = LuaX.Renderer
local WiboxElement = require("lib.LuaX.util.NativeElement.WiboxElement")
local create_element = LuaX.create_element
local Console = require("src.awesome.ui.Console.Console")
local ScreenContext = require("src.awesome.ui.ScreenContext")

local function console_install_on_focused ()
    local focused = awful.screen.focused()

    if not focused then
        log.error("No focused screen - cannot create Console")
    end

    local element = create_element(ScreenContext.Provider, {
        value = focused,
        children = { create_element(Console, {}) }
    })

    local root = WiboxElement.get_root(focused.taskbar.widget)

    local renderer = Renderer()

    renderer:render(element, root)
end

return console_install_on_focused