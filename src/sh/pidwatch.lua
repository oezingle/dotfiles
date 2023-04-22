
local awful = require("awful")

-- keep a process around so long as awesome is active
---@param command string
---@param silent boolean?
local function pidwatch(command, silent)
    silent = silent or false

    -- only drawback of this method is that it doesn't handle crashes
    local pid = awful.spawn.with_shell(command .. (silent and " > /dev/null 2>&1" or ""))

    awesome.connect_signal("exit", function()
        -- -pid = kill group
        awesome.kill(-pid, awesome.unix_signal.SIGTERM)
    end)
end

return pidwatch