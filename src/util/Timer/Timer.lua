
local has_gears, gtimer = pcall(require, "gears.timer")

log.debug(string.format("Timer using %s", has_gears and "gears.timer" or "GLibTimer" ))

if has_gears then
    return gtimer --[[ @as Zingle.Timer ]]
end

---@type Zingle.Timer
local timer = require("src.util.Timer.GLibTimer")

return timer