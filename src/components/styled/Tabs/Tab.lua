
local LuaX = require("lib.LuaX")
local use_context = LuaX.use_context
local create_element = LuaX.create_element

local TabsContext = require("src.components.styled.Tabs.internal.TabsContext")

local Tab = function (props)
    local name = assert(props.name, "All tabs must have an associated name")

    local tabs_context = use_context(TabsContext)
    
    local new_tabs_context = { tab_name = name }
    for k, v in pairs(tabs_context) do
        new_tabs_context[k] = v
    end

    return create_element(TabsContext.Provider, { value = new_tabs_context, children = props.children })
end

return Tab