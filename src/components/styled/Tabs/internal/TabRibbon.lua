
local LuaX = require("lib.LuaX")
local use_portal = LuaX.use_portal

local Flex = require("src.components.base.Flex")

local TabRibbon = LuaX(function (props)
    local TabButtonPortal = use_portal("tab-button")

    -- TODO seems to have no effect on exit button.
    return [[
        <Flex align="stretch">
            <TabButtonPortal.Outlet/>
        </Flex>
    ]]
end)

return TabRibbon