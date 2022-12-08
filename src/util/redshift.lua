-- Modified from https://github.com/troglobit/awesome-redshift

local spawn = require("awful.spawn")

local redshift = {}

redshift.path    = "/usr/bin/redshift"
redshift.method  = "randr"
redshift.options = ""
redshift.state   = 1

--- Dim the screen using redshift
---@param force boolean?
function redshift.dim(force)
    if redshift.state == 0 or force then
        if redshift.method == "randr" then
            spawn(redshift.redshift .. " -m randr -o " .. redshift.options)
        elseif redshift.method == "vidmode" then
            local screens = screen.count()

            for i = 0, screens - 1 do
                spawn(redshift.path .. " -m vidmode:screen=" .. tostring(i) ..
                    " -o " .. redshift.options)
            end
        end
    end
end

--- Undim the screen using redshift
function redshift.undim()
    if redshift.method == "randr" then
        spawn(redshift.path .. " -m randr -x " .. redshift.options)
    elseif redshift.method == "vidmode" then
        local screens = screen.count()

        for i = 0, screens - 1 do
            spawn(redshift.path .. " -m vidmode:screen=" .. i ..
                " -x " .. redshift.options)
        end
    end
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
end)

return redshift