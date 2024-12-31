
local LuaX = require("lib.LuaX")
local use_portal = LuaX.use_portal
local use_context = LuaX.use_context
local TabsContext = require("src.components.styled.Tabs.internal.TabsContext")

local Background = require("src.components.base.Background")

local TabContent = LuaX(function (props)
    local Portal = use_portal("tab-content")
    
    local tab_context = use_context(TabsContext)
    local selected = tab_context.selected == tab_context.tab_name

    return [[
        <>
            {selected and <Portal.Inlet>
                <Background flex-grow={1}>
                    {props.children}
                </Background>
            </Portal.Inlet>}
        </>
    ]]
end)

return TabContent