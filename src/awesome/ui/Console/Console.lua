local use_state = require("lib.LuaX.hooks.use_state")
local use_context = require("lib.LuaX.hooks.use_context")
local ScreenContext = require("src.awesome.ui.ScreenContext")
local LuaX = require("lib.LuaX")
local Wibox = require("src.components.awesome.Wibox")
local Text = require("src.components.Text")
local Margin = require("src.components.Margin")
local map = require("src.polyfill.list.map")

local Background = require("src.components.Background")

local Tabs = require("src.components.styled.Tabs.Tabs")
local Tab = require("src.components.styled.Tabs.Tab")
local TabLabel = require("src.components.styled.Tabs.TabLabel")
local TabContent = require("src.components.styled.Tabs.TabContent")
local TabRibbonButton = require("src.components.styled.Tabs.TabRibbonButton")

local Console = LuaX(function()
    local is_visible, set_visible = use_state(true)

    local function console_close()
        set_visible(false)
    end

    local screen = use_context(ScreenContext)

    local geom = screen.geometry
    local half_height = geom.height / 2

    local tabs = {
        {
            tag = "logs",
            name = "Logs"
        },
        {
            tag = "components",
            name = "Components"
        },
        {
            tag = "wiboxes",
            name = "Wiboxes"
        },
        {
            tag = "shell",
            name = "Lua shell"
        }
    }

    return [[
        <Wibox
            screen={screen} name="Console"
            visible={is_visible}

            x={0}
            y={half_height}
            width={geom.width}
            height={half_height}

            color="#222222"
        >
            <Tabs initial={tabs[1].name}>
                <TabRibbonButton text_color="#ff0000" onclick={console_close}>⨯</TabRibbonButton>
        
                {map(tabs, function (tab)
                    return (
                        <Tab name={tab.tag}>
                            <TabLabel>{tab.name}</TabLabel>
                        </Tab>
                    )
                end)}
            </Tabs>
        </Wibox>
    ]]
end)

return Console
