local list_reverse = require("src.polyfill.list.reverse")
local merge_props = require("src.components.helper.merge_props")
local mouse_props = require("src.components.provider.awesome.helper.mouse_props")
local default_props = require("src.components.provider.awesome.helper.default_props")

local LuaX = require("lib.LuaX")
local create_element = LuaX.create_element

---@param props Zingle.Components.FlexProps
local Flex = LuaX(function (props)
    local children = props.reverse and list_reverse(props.children) or props.children

    return create_element("wibox.mod.flexbox", merge_props({
        justify = props.justify,
        align = props.align,
        direction = props.direction,
        gap = props.gap,

        children = children,
    }, mouse_props.create(props), default_props(props)))
end)

return Flex
