local spawn = require("src.agnostic.spawn.promise")
local Promise = require("src.util.Promise")

-- TODO new version where dependencies are stored in a true/false table and if a false is found,
-- TODO the function calls Promise.resolve(false), and then calls which for every dependency. If
-- TODO a true is found, save it and move onto the next, whereas a false resolves false

---@type table<string, boolean>
local dependencies = {}

---@param dependency string
---@return Promise<boolean>
local function check_dependency(dependency)
    if dependencies[dependency] == true then
        return Promise.resolve(true)
    elseif dependencies[dependency] == false then
        return Promise.resolve(false)
    else
        local cmd = string.format("which %s > /dev/null && printf y", dependency)

        return spawn(cmd)
            :after(function(response)
                return response == "y" or response == "y\n"
            end)
            :after(function(found)
                dependencies[dependency] = found

                return found
            end)
    end
end

--- Check if dependencies are installed, returning a promise of if they are
---@param dependencies string|string[]
---@return Promise<boolean>
local function check_dependencies(dependencies)
    if type(dependencies) == "string" then dependencies = { dependencies } end

    local checks = {}

    for _, dependency in ipairs(dependencies) do
        table.insert(checks, check_dependency(dependency))
    end

    return Promise.all(checks)
        :after(function (checks) 
            for _, check in ipairs(checks) do
                if not check[1] then
                    return false 
                end
            end

            return true
        end)
end

return check_dependencies
