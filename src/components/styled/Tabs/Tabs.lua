
local LuaX = require("lib.LuaX")

local TabsProvider = require("src.components.styled.Tabs.internal.TabsProvider")

local TabRibbon = require("src.components.styled.Tabs.internal.TabRibbon")
local CurrentTabContent = require("src.components.styled.Tabs.internal.CurrentTabContent")

-- TODO FIXME generic containers!
local Tabs = LuaX(function (props)
    return [[
        <TabsProvider Button={props.Button} initial={props.initial}>
            <wibox.layout.align.vertical>
                <TabRibbon/>

                <CurrentTabContent />

                {props.children}
            </wibox.layout.align.vertical>
        </TabsProvider>
    ]]
end)

return Tabs