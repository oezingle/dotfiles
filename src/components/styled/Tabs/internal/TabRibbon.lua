
local LuaX = require("lib.LuaX")
local use_portal = LuaX.use_portal

local Flex = require("src.components.Flex")

local TabRibbon = LuaX(function (props)
    local TabButtonPortal = use_portal("tab-button")

    return [[
        <Flex>
            <TabButtonPortal.Outlet/>
        </Flex>
    ]]
end)

return TabRibbon