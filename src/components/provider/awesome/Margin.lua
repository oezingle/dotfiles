
local LuaX = require("lib.LuaX")
local default_props = require("src.components.provider.awesome.helper.default_props")
local create_element = LuaX.create_element

local merge_props = require("src.components.helper.merge_props")
local mouse_props = require("src.components.provider.awesome.helper.mouse_props")

---@param props Zingle.Awesome.Components.MarginProps
local Margin = function (props)
    local left = props.left or props.x or props.margin
    local right = props.right or props.x or props.margin

    local top = props.top or props.y or props.margin
    local bottom = props.bottom or props.y or props.margin

    return create_element("wibox.container.margin", merge_props({
        left = left,
        right = right,
        top = top,
        bottom = bottom,

        children = props.children
    }, mouse_props.create(props), default_props(props)))
end

return Margin