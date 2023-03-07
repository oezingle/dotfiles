
local spawn = require("src.agnostic.spawn")
local Promise = require("src.util.Promise")

---@param command string
---@return Promise<string>
local function spawn_promise (command)
    return Promise(function (res)
        spawn(command, res)
    end)
end

return spawn_promise