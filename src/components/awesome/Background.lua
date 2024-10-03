local LuaX = require("lib.LuaX")
local create_element = LuaX.create_element

local merge_props = require("src.components.helper.merge_props")
local mouse_props = require("src.components.awesome.helper.mouse_props")

local rounded_rect = require("src.components.awesome.helper.rounded_rect")

---@param props Zingle.Awesome.Components.BackgroundProps
local Background = function(props)
    return create_element("wibox.container.background", merge_props({
        border_strategy = "inner",
        border_width = props["border-width"],
        border_color = props["border-color"],

        bg = props.color,
        shape = rounded_rect.get(props.radius),

        children = props.children
    }, mouse_props.create(props)))
end

return Background
