
local LuaX = require("lib.LuaX")

local TabsProvider = require("src.components.styled.Tabs.internal.TabsProvider")

local TabRibbon = require("src.components.styled.Tabs.internal.TabRibbon")
local CurrentTabContent = require("src.components.styled.Tabs.internal.CurrentTabContent")

local Flex = require("src.components.base.Flex")

local Tabs = LuaX(function (props)
    return [[
        <TabsProvider Button={props.Button} initial={props.initial}>
            <Flex direction="vertical">
                <TabRibbon/>

                <CurrentTabContent />
            </Flex>

            {props.children}
        </TabsProvider>
    ]]
end)

return Tabs