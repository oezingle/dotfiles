local Awesome               = require("lib.awesome_capi")

local LuaX                  = require("lib.LuaX")
local use_state             = LuaX.use_state

local Flex                  = require("src.components.base.Flex")
local Margin                = require("src.components.base.Margin")
local Text                  = require("src.components.base.Text")
local Background            = require("src.components.base.Background")

local SelectedWidgetContext = require("src.awesome.ui.Console.WiboxesContent.SelectedWidgetContext")
local WidgetDropdown        = require("src.awesome.ui.Console.WiboxesContent.WidgetDropdown")

local use_style = require("src.components.styled.helper.use_style")

local WiboxesContent = LuaX(function()
    local style = use_style()

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

    local selected_widget, set_selected_widget = use_state(nil)

    return [[
        <Flex direction="vertical" flex-grow={1}>
            <Flex>
                <Text onclick={on_select_wibox} color={is_selecting_wibox and style.colors.text.muted or style.colors.text.clickable}>
                    {is_selecting_wibox and "Selecting Wibox..." or "Select a Wibox"}
                </Text>
            </Flex>

            <Flex flex-grow={1}>
                <Background flex-grow={2} border-width={3} border-color="#777777">
                    <SelectedWidgetContext.Provider value={{
                        selected        = selected_widget,
                        set_selected    = set_selected_widget
                    }}>
                        {current_wibox and <WidgetDropdown widget={current_wibox.widget} />}
                    </SelectedWidgetContext.Provider>
                </Background>

                <Background flex-grow={1} border-width={3} border-color="#777777">
                    {selected_widget and 
                        <>
                            <Flex>

                            </Flex>
                        </> or
                        <Text>Select a widget to see its properties here</Text>
                    }
                </Background>
            </Flex>
        </Flex>
    ]]
end)

return WiboxesContent
