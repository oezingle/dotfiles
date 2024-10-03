local LuaX = require("lib.LuaX")
local create_element = LuaX.create_element

local includes = require("src.polyfill.list.includes")

---@alias Zingle.Awesome.Components.SystrayProps { direction: Awesome.Direction }
---@alias Zingle.Awesome.Components.Systray LuaX.Component<Zingle.Awesome.Components.SystrayProps>

local Systray = function(props)
    local horizontal = includes({ "left", "right" }, props.direction)
    local reverse = includes({ "left", "bottom" }, props.direction)

    return create_element("wibox.widget.systray", {
        horizontal = horizontal,
        reverse = reverse
    })
end

return Systray