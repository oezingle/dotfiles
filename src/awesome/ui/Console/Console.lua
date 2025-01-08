local use_state = require("lib.LuaX.hooks.use_state")
local use_context = require("lib.LuaX.hooks.use_context")
local ScreenContext = require("src.awesome.ui.ScreenContext")
local LuaX = require("lib.LuaX")
local Wibox = require("src.components").Wibox
local map = require("src.polyfill.list.map")

local Tabs = require("src.components.styled.Tabs.Tabs")
local Tab = require("src.components.styled.Tabs.Tab")
local TabLabel = require("src.components.styled.Tabs.TabLabel")
local TabContent = require("src.components.styled.Tabs.TabContent")
local TabRibbonButton = require("src.components.styled.Tabs.TabRibbonButton")

local LogsContent = require("src.awesome.ui.Console.LogsContent")
local WiboxesContent = require("src.awesome.ui.Console.WiboxesContent")

local GridTest =require("GridTest")

local Console = LuaX(function(props)
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
            name = "Logs",
            content = LuaX.create_element(LogsContent, {})
        },
        {
            tag = "components",
            name = "Components"
        },
        {
            tag = "wiboxes",
            name = "Wiboxes",
            content = LuaX.create_element(WiboxesContent, {})
        },
        {
            tag = "shell",
            name = "Lua shell"
        },
        -- TODO remove
        {
            tag = "grid-test",
            name = "GridTest",
            content = LuaX.create_element(GridTest, {})
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
            <Tabs initial={tabs[1].tag}>
                <TabRibbonButton text_color="#ff0000" onclick={console_close}>⨯</TabRibbonButton>

                {map(tabs, function (tab)
                    return (
                        <Tab name={tab.tag}>
                            <TabLabel>{tab.name}</TabLabel>

                            <TabContent>
                                {tab.content}
                            </TabContent>
                        </Tab>
                    )
                end)}
            </Tabs>
        </Wibox>
    ]]
end)

return Console
