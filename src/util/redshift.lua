-- Modified from https://github.com/troglobit/awesome-redshift

local spawn = require("awful.spawn")

local redshift = {}

redshift.path  = "/usr/bin/redshift"
redshift.state = 1
redshift.pid   = nil

--- Dim the screen using redshift
---@param force boolean?
function redshift.dim(force)
    if redshift.state == 0 or force then
        redshift.pid = spawn(redshift.path .. " -m randr")

        redshift.state = 1
    end
end

--- Undim the screen using redshift
function redshift.undim()
    if redshift.pid ~= nil then
        awesome.kill(-redshift.pid, awesome.unix_signal['SIGTERM'])
        
        redshift.pid = nil
    end
    
    redshift.state = 0
end

--- Toggle redshift dimming
function redshift.toggle()
    if redshift.state == 1 then
        redshift.undim()
    else
        redshift.dim()
    end
end

--- Initialize redshift
---@param state number?
function redshift.init(state)
    if state == 1 then
        redshift.dim(true)
    else
        redshift.undim()
    end
end

awesome.connect_signal("exit", function()
    redshift.undim()

    -- TODO doesn't exit right
    spawn.with_shell("kill $(pidof redshift)")
end)

return redshift
