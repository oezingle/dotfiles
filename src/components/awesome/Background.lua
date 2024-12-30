local LuaX = require("lib.LuaX")
local create_element = LuaX.create_element

local merge_props = require("src.components.helper.merge_props")
local mouse_props = require("src.components.awesome.helper.mouse_props")
local default_props = require("src.components.awesome.helper.default_props")

local rounded_rect = require("src.components.awesome.helper.rounded_rect")

---@param props Zingle.Awesome.Components.BackgroundProps
local Background = function(props)
    local border_width = props["border-width"]
    local border_color = props["border-color"]
    local radius = props.radius

    return create_element("wibox.container.background", merge_props({
        -- newer API spec
        border_width = border_width,
        border_color = border_color,

        -- older API spec
        shape_border_width = border_width,
        shape_border_color = border_color,

        bg = props.color,
        shape = rounded_rect.get(radius),

        -- offset content by border size
        children = border_width and create_element("wibox.container.margin", {
            left = border_width,
            right = border_width,
            top = border_width,
            bottom = border_width,
            children = props.children
        }) or props.children
    }, mouse_props.create(props), default_props(props)))
end

return Background
