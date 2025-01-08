local map                   = require("src.polyfill.list.map")
local LuaX                  = require("lib.LuaX")
local use_state             = LuaX.use_state
local use_effect            = LuaX.use_effect
local use_context           = LuaX.use_context
local Flex                  = require("src.components.base.Flex")
local Margin                = require("src.components.base.Margin")
local Text                  = require("src.components.base.Text")
local Background            = require("src.components.base.Background")
local use_style             = require("src.components.styled.helper.use_style")
local use_hoverable         = require("src.components.styled.helper.use_hoverable")
local SelectedWidgetContext = require("src.awesome.ui.Console.WiboxesContent.SelectedWidgetContext")

-- Arrows from https://stackoverflow.com/questions/2701192/what-characters-can-be-used-for-up-down-triangle-arrow-without-stem-for-displa


local WidgetDropdown = nil


WidgetDropdown = LuaX(function(props)
    local style = use_style()

    local widget = props.widget

    local widget_context = use_context(SelectedWidgetContext)

    local open, set_open = use_state(false)
    local toggle_open = function()
        set_open(function(open) return not open end)
    end

    local arrow_hover = use_hoverable()
    local bg_hover = use_hoverable(widget == widget_context.selected, {
        selected = style.colors.text.clickable,
        hover = "#3f6791",

        default = "#222222"
    })

    -- Automatically close on widget layout
    do
        local on_widget_layout = function()
            set_open(false)
        end
        use_effect(function()
            widget:connect_signal("widget::layout_changed", on_widget_layout)

            return function()
                widget:disconnect_signal("widget::layout_changed", on_widget_layout)
            end
        end, { widget })
    end

    local is_selected = widget_context.selected
    local has_children = #widget.children ~= 0
    local depth = props.depth or 0

    -- hack to get around LuaX inline doing lazy locals evaluation.
    local Dropdown = WidgetDropdown

    -- TODO is widget_context.set_selected a dead value?

    -- TODO only one child visible??
    return [[
        <Flex direction="vertical">
            <Background
                color={bg_hover.color}
                onhover={bg_hover.onhover}
                onleave={bg_hover.onleave}
            >
                <Margin left={depth * 15 + 3} right={3}>
                    <Flex gap={2}>
                        {has_children and
                            <Text
                                onclick={toggle_open}
                                onhover={arrow_hover.onhover}
                                onleave={arrow_hover.onleave}
                                color={arrow_hover.color}
                            >
                                {open and "▼" or "►"}
                            </Text>
                        }

                        <Text onclick={function ()
                            -- TODO breaks everything.
                            -- print(widget, widget_context.set_selected)
                            
                            widget_context.set_selected(widget) 
                        end}>
                            {widget.widget_name}
                        </Text>
                    </Flex>
                </Margin>
            </Background>

            <>
                {open and map(widget.children, function (child)
                    return (
                        <Dropdown widget={child} depth={depth + 1} />
                    )
                end)}
            </>
        </Flex>
    ]]
end)

return WidgetDropdown
