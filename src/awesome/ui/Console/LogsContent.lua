
local LuaX = require("lib.LuaX")
local Text = require("src.components.base.Text")

local LogsContent = LuaX(function ()
    local input = io.stdout

    -- local content = input:read("*a")
    local content = "bruh"

    return [[
        <Text size={9}>
            {content}
        </Text>
    ]]
end)

return LogsContent