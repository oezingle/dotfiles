
local LuaX = require("lib.LuaX")
local create_element = LuaX.create_element

local merge_props = require("src.components.helper.merge_props")
local mouse_props = require("src.components.awesome.helper.mouse_props")

---@param props Zingle.Awesome.Components.MarginProps
local Margin = function (props)
    props.left = props.left or props.x
    props.right = props.right or props.x

    props.top = props.top or props.y
    props.bottom = props.bottom or props.y

    return create_element("wibox.container.margin", merge_props({
        left = props.left,
        right = props.right,
        top = props.top,
        bottom = props.bottom,

        children = props.children
    }, mouse_props.create(props)))
end

return Margin