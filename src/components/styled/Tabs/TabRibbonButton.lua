local LuaX = require("lib.LuaX")
local use_portal = LuaX.use_portal
local use_context = LuaX.use_context
local TabsContext = require("src.components.styled.Tabs.internal.TabsContext")
local DefaultTabButton = require("src.components.styled.Tabs.internal.DefaultTabButton")

local TabRibbonButton = LuaX(function (props)
    local Portal = use_portal("tab-button")

    local Button = use_context(TabsContext).Button or DefaultTabButton

    return [[
        <Portal.Inlet>
            <Button 
                selected={props.selected}
                onclick={props.onclick}
                text_color={props.text_color} 
            >
                {props.children}
            </Button>
        </Portal.Inlet>
    ]]
end)

return TabRibbonButton