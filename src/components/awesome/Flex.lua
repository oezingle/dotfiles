local list_reverse = require("src.polyfill.list.reverse")
local merge_props = require("src.components.helper.merge_props")
local mouse_props = require("src.components.awesome.helper.mouse_props")
local default_props = require("src.components.awesome.helper.default_props")
local Children = require("lib.LuaX.Children")
local reduce = require("src.polyfill.list.reduce")

local LuaX = require("lib.LuaX")
local create_element = LuaX.create_element
local use_state = LuaX.use_state
local use_effect = LuaX.use_effect

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

--[[
---@param props Zingle.Awesome.Components.FlexProps
local Flex = function(props)
    local children = props.reverse and list_reverse(props.children or {}) or props.children

    local justify = props["justify"] or "center"

    local direction = props.direction or "horizontal"

    local widget, set_widget = use_state(nil)

    use_effect(function()
        if not widget then return end

        local grow_modified = false

        local ratio = {}

        Children.map(children, function(child, index)
            local grow = child.props["flex-grow"]

            if grow then
                grow_modified = true
            end
            ratio[index] = grow or 1
        end)

        local ratio_total = reduce(ratio, function(total, current)
            return total + current
        end, 0)

        if grow_modified then
            for index, value in ipairs(ratio) do
                local ratio_value = value / ratio_total

                widget._private.ratios[index] = ratio_value
            end
            widget:emit_signal("widget::layout_changed")
        end
    end, { widget, children })

    return create_element("wibox.layout.ratio." .. direction, merge_props({
        children = Children.map(children, function (child)
            -- TODO there MUST be a better solution than this!
            -- wrap child in a ratio in case it is a function that spawns multiple children.
            return create_element("wibox.layout.flex.horizontal", { children = child })
        end),
        spacing = props.gap,

        inner_fill_strategy = translate_justify(justify),

        ["LuaX::onload"] = function(_, widget)
            set_widget(widget)

            print(widget)
            for k, v in pairs(widget) do
                print("", k, v)
            end
        end
    }, mouse_props.create(props), default_props(props)))
end
]]

--[[
    manual justify modes:
        start - no-op
        end - calculate space left, use that as x offset
        center - calcuate space left, use half that as x offset
        expand - not included in flexbox docs
        space-around - calculate space left, use 1/(n+1) as x offset (where n is count of children)
        space-between - calculate space left, use 1/(n-1) as x offset (where n is count of children)
]]

--[[
---@param props Zingle.Awesome.Components.FlexProps
local Flex = LuaX(function(props)
    local direction = props.direction or "horizontal"

    local justify = props["justify"] or "center"

    local on_layout = function (widget)
        local reverse = props.reverse

        local is_horizontal = direction == "horizontal"
        local coordinate_of_interest = is_horizontal and "x" or "y"
        local edge_of_interest = is_horizontal and "width" or "height"
        
        local parent_size = nil

        local static_size = 0
        -- calculate static size
        for i, child in ipairs(widget.children) do
            print(child:fit(20, 20))
        end
    end

    return create_element("wibox.layout.manual", merge_props({
        children = props.children,

        ["signal::widget::layout_changed"] = on_layout
    }))
end)
]]

---@param props Zingle.Awesome.Components.FlexProps
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
