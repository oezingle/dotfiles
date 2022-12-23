local spawn = require("awful.spawn")

local SaveState = require("src.save_state")

local redshift_state = SaveState("redshift.json", {
    default = {
        state = 1,
    }
}):get_contents()

--[[
local redshift_state = {
    path = "/usr/bin/redshift",
    state = 1,
    pid = nil
}
]]

local redshift = {
    pid = nil,
    path = "/usr/bin/redshift",
}

--- Dim the screen using redshift
---@param force boolean?
function redshift.dim(force)
    if redshift_state.state == 0 or force then
        redshift.pid = spawn(redshift.path .. " -m randr")

        redshift_state.state = 1
    end
end

function redshift.kill()
    if redshift.pid ~= nil then
        awesome.kill(-redshift.pid, awesome.unix_signal['SIGTERM'])

        redshift.pid = nil
    end
end

--- Undim the screen using redshift
function redshift.undim()
    redshift.kill()    

    redshift_state.state = 0
end

--- Toggle redshift dimming
function redshift.toggle()
    if redshift_state.state == 1 then
        redshift.undim()
    else
        redshift.dim()
    end
end

--- Initialize redshift
function redshift.init()
    if redshift_state.state == 1 then
        redshift.dim(true)
    else
        redshift.undim()
    end
end

function redshift.get_state()
    return redshift_state.state
end 

awesome.connect_signal("exit", function()
    redshift.kill()

    -- TODO doesn't exit right
    spawn.with_shell("killall redshift")
end)

return redshift
