
local LuaX = require("lib.LuaX")
local default_props = require("src.components.provider.awesome.helper.default_props")
local create_element = LuaX.create_element

local merge_props = require("src.components.helper.merge_props")
local mouse_props = require("src.components.provider.awesome.helper.mouse_props")

---@param props Zingle.Awesome.Components.TextProps
local Text = function (props)
    local font = props.font or "Monospace"
    local size = props.size or 10

    return create_element("wibox.container.background", {
        fg = props.color,
        children = create_element("wibox.widget.textbox", merge_props({
            font = string.format("%s %d", font, size),
    
            children = props.children
        }, mouse_props.create(props), default_props(props)))
    })
end

return Text