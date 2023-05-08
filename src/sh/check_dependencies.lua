
local spawn = require("src.agnostic.spawn.promise")

--- Check if dependencies are installed, returning a promise of if they are
---@param dependencies string|string[]
---@return Promise<boolean>
local function check_dependencies (dependencies)
    if type(dependencies) == "string" then dependencies = { dependencies} end

    local lines = {}
    
    for _, dependency in ipairs(dependencies) do
        table.insert(lines, string.format("which %s > /dev/null", dependency))
    end

    local cmd = table.concat(lines, " && ") .. " && printf success"

    return spawn(cmd)
        :after(function (response)
            return response == "success" or response == "success\n"
        end)
end

return check_dependencies