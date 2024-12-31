local Awesome    = require("lib.awesome_capi")
local map        = require("src.polyfill.list.map")

local LuaX       = require("lib.LuaX")
local use_state  = LuaX.use_state
local use_effect = LuaX.use_effect

local Flex       = require("src.components.base.Flex")
local Margin     = require("src.components.base.Margin")
local Text       = require("src.components.base.Text")
local Background = require("src.components.base.Background")

-- TODO more (simple) container types

local WidgetDropDown = nil
WidgetDropDown = LuaX(function(props)
    local open, set_open = use_state(false)
    local toggle_open = function()
        set_open(function(open) return not open end)
    end

    local widget = props.widget

    local on_widget_layout = function ()
        set_open(false)
    end
    use_effect(function ()
        widget:connect_signal("widget::layout_changed", on_widget_layout)

        return function ()
            widget:disconnect_signal("widget::layout_changed", on_widget_layout)
        end
    end, { widget })

    -- hack to get around LuaX inline doing lazy locals evaluation.
    local Dropdown = WidgetDropDown

    -- TODO only one child visible?
    return [[
        <Background onclick={toggle_open}>
            <Flex direction="vertical">
                <Flex gap={2}>
                    <Text>{open and "v" or ">"}</Text>

                    <Text>{widget.widget_name}</Text>
                </Flex>

                <Margin left={15}>
                    {open and map(widget.children, function (child)
                        return <Dropdown widget={child} />
                    end)}
                </Margin>
            </Flex>
        </Background>
    ]]
end)

local WiboxesContent = LuaX(function()
    local is_selecting_wibox, set_selecting_wibox = use_state(false)
    local current_wibox, set_current_wibox = use_state(nil)
    local function on_select_wibox()
        set_selecting_wibox(true)

        mousegrabber.run(function(coords)
            if coords.buttons[Awesome.Mouse.MouseButton.LEFT] then
                -- TODO toast if mouse.current_wibox == nil

                set_current_wibox(mouse.current_wibox)

                set_selecting_wibox(false)

                return false
            end

            return true
        end, "crosshair")
    end

    return [[
        <Flex direction="vertical" flex-grow={1}>
            <Flex>
                <Text onclick={on_select_wibox} color={not is_selecting_wibox and "#007bff"}>
                    {is_selecting_wibox and "Selecting Wibox..." or "Select a Wibox"}
                </Text>
            </Flex>

            <Flex flex-grow={1}>
                <Background flex-grow={2}>
                    {current_wibox and <WidgetDropDown widget={current_wibox.widget} />}
                </Background>

                <Background flex-grow={1} border-width={5} border-color="#ff0000">
                    <Text>bruh</Text>
                </Background>
            </Flex>
        </Flex>
    ]]
end)

return WiboxesContent
