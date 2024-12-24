
local LuaX = require("lib.LuaX")
local use_portal = LuaX.use_portal

local CurrentTabContent = LuaX(function ()
    local Portal = use_portal("tab-content")

    return [[
        <Portal.Outlet />
    ]]
end)

return CurrentTabContent