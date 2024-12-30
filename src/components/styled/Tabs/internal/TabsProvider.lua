
local LuaX = require("lib.LuaX")

local Portal = LuaX.Portal
local use_memo = LuaX.use_memo
local use_state = LuaX.use_state

local TabsContext = require("src.components.styled.Tabs.internal.TabsContext")

local TabsProvider = LuaX(function (props)
    local TabButtonPortal = use_memo(function ()
        return Portal.create("tab-button")
    end, {})

    local TabContentPortal = use_memo(function ()
        return Portal.create("tab-content")
    end, {})

    local selected, set_selected = use_state(props.initial)

    return [[
        <TabsContext.Provider value={{ 
            selected = selected, 
            set_selected = set_selected, 
            Button = props.Button 
        }}>
            <TabButtonPortal.Provider>
                <TabContentPortal.Provider>
                    {props.children}
                </TabContentPortal.Provider>
            </TabButtonPortal.Provider>
        </TabsContext.Provider>
    ]]
end)

return TabsProvider