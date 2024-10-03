
local LuaX = require("lib.LuaX")
local create_element = LuaX.create_element

local merge_props = require("src.components.helper.merge_props")
local mouse_props = require("src.components.awesome.helper.mouse_props")

---@param props Zingle.Awesome.Components.TextProps
local Text = function (props)
    local font = props.font or "Monospace"
    local size = props.size or 10

    return create_element("wibox.widget.textbox", merge_props({
        font = string.format("%s %d", font, size),
        color = props.color,

        children = props.children
    }, mouse_props.create(props)))
end

return Text