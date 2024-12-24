
local LuaX = require("lib.LuaX")
local use_context = LuaX.use_context
local TabsContext = require("src.components.styled.Tabs.internal.TabsContext")
local TabRibbonButton = require("src.components.styled.Tabs.TabRibbonButton")

local TabLabel = LuaX(function (props)
    local tab_context = use_context(TabsContext)
    local name = assert(tab_context.tab_name, "Tabs must have names")

    local set_selected = tab_context.set_selected

    local selected = tab_context.selected == name

    return [[
        <TabRibbonButton selected={selected} onclick={function ()
            set_selected(name)
        end}>
            {props.children}
        </TabRibbonButton>
    ]]
end)

return TabLabel