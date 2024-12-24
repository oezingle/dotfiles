
local LuaX = require("lib.LuaX")
local use_portal = LuaX.use_portal

local DefaultTabButton = require("src.components.styled.Tabs.internal.DefaultTabButton")

local TabRibbon = LuaX(function (props)
    local TabButtonPortal = use_portal("tab-button")

    -- TODO FIXME switch to a generic container.
    return [[
        <wibox.layout.fixed.horizontal>
            <TabButtonPortal.Outlet />
        </wibox.layout.fixed.horizontal>
    ]]
end)

return TabRibbon