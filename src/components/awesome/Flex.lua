local list_reverse = require("src.polyfill.list.reverse")
local merge_props = require("src.components.helper.merge_props")
local mouse_props = require("src.components.awesome.helper.mouse_props")
local default_props = require("src.components.awesome.helper.default_props")
local Children = require("lib.LuaX.Children")
local reduce = require("src.polyfill.list.reduce")

local LuaX = require("lib.LuaX")
local create_element = LuaX.create_element

--- Translate justify to inner_fill_strategy 
---
--- https://awesomewm.org/doc/api/classes/wibox.layout.ratio.html#wibox.layout.ratio.inner_fill_strategy
---@alias justify Zingle.Awesome.Components.FlexProps.Justify?
local function translate_justify(justify)
    local justify = justify or "center"

    local translation = ({
        ["start"]         = "left",
        ["end"]           = "right",
        ["center"]        = "center",
        ["expand"]        = "justify",
        ["space-around"]  = "spacing",
        ["space-between"] = "inner_spacing"
    })[justify]

    if not translation then
        log.error(string.format("Unknown justify mode %q", justify))
        
        return "center"
    end

    return translation
end

-- TODO FIXME wibox.layout.ratio seems broken!

---@param props Zingle.Awesome.Components.FlexProps
local Flex = function(props)
    local children = props.reverse and list_reverse(props.children or {}) or props.children
        
    local justify = props["justify"] or "center"

    local direction = props.direction or "horizontal"

    local ratio = {}

    return create_element("wibox.layout.flex." .. direction, merge_props({
        children = Children.map(children, function (child, index)
            local grow = child.props["flex-grow"]
            
            if grow then
                ratio[index] = grow or 0
            end

            return child
        end),
        spacing = props.gap,

        inner_fill_strategy = translate_justify(justify),

        ["LuaX::onload"] = function (_, widget)
            local ratio_total = reduce(ratio, function (total, current)
                return total + current
            end, 0)
        
            for index, value in ipairs(ratio) do
                widget:set_ratio(index, value / ratio_total)
            end
        end
    }, mouse_props.create(props), default_props(props)))
end

return Flex
