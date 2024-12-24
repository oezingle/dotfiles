local create_element = require("lib.LuaX").create_element
local merge_props = require("src.components.helper.merge_props")
local mouse_props = require("src.components.awesome.helper.mouse_props")
local default_props = require("src.components.awesome.helper.default_props")

---@param props Zingle.Awesome.Components.CenterProps
local function Center(props)    
    return create_element("wibox.container.place", merge_props({
        children = props.children,

        halign = props.horizontal,
        valign = props.vertical,
    }, mouse_props.create(props), default_props(props)))
end

return Center