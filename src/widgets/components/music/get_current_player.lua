
local spawn = require("src.agnostic.spawn")


local cmd = 
"for player in $(playerctl -l); do " .. 
    "if [[ $(playerctl -p $player status) == \"Playing\" ]]; then " .. 
        "echo $player;".. 
    "fi;" .. 
"done"

--- Get the topmost playing player
---@param callback fun(player: string|nil): any
local function get_current_player (callback)
    spawn(cmd, function (res)
        local s_start, s_end = string.find(res, "[^\n]+")

        if s_start == s_end then
            callback(nil)
        else
            local sub = string.sub(res, s_start, s_end)

            callback(sub)
        end
    end)
end

return get_current_player