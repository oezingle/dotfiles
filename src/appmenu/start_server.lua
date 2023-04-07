
--- Use file require arguments to figure out the path of the server
local cmd = (...)
    :gsub("start_server", "")
    :gsub("%.", "/")
    .. "server/main"

local function start_server()
    if awesome then
        ---@type string
        local dir = require("gears.filesystem").get_configuration_dir()

        local spawn = require("awful.spawn")

        local pid = spawn(dir .. cmd)

        -- TODO calls every restart too - fix this somehow?
        awesome.connect_signal("exit", function ()
            awesome.kill(-pid, awesome.unix_signal.SIGTERM)
        end)
    else
        io.popen(cmd)
    end
end

return start_server
