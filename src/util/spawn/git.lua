-- TODO load shimmed version of spawn to do this work with Promises and a visible loader, then teardown and load dependencies as normal
-- minimal 30log clone
-- log = { debug = print }

local Promise = require("src.polyfill.Promise")
local spawn   = require("src.util.spawn")
local which   = require("src.util.spawn.which")

local git     = {
    _cache = {}
}

---@return Promise<boolean>
function git.has()
    if git._cache.has ~= nil then
        return Promise.resolve(git._cache.has)
    end

    return which("git")
        :after(function(loc)
            local has = loc ~= nil

            git._cache.has = has

            return has
        end)
        :catch(function()
            git._cache.has = false

            return false
        end)
end

function git.is()
    return git.has()
        :after(function(has)
            if not has then
                return false
            end

            if git._cache.is ~= nil then
                return git._cache.is
            end

            return spawn("git status 2>&1")
                :after(function(ret)
                    local stdout = ret.stdout

                    local is_fatal = stdout:match("Fatal:")
                    local is = is_fatal == nil

                    git._cache.is = is

                    return is
                end)
                :catch(function(err)
                    git._cache.is = false

                    return false
                end)
        end)
end

---@return Promise<string[]>
function git.submodules_needs()
    return git.is()
        :after(function(is)
            if not is then
                return {}
            end
            
            return spawn("git submodule status")
                :after(function(ret)
                    local stdout = ret.stdout

                    stdout = "\n" .. stdout

                    local modules = {}
                    for module in stdout:gmatch("\n%-%S+%s+(%S+)") do
                        table.insert(modules, module)
                    end

                    return modules
                end)
        end)
end

-- Initialize submodules
function git.submodules_init()
    return git.is() 
        :after(function (is)            
            if not is then
                return
            end

            return spawn("git submodule update --init --recursive")
        end)
end

function git.submodules_deinit()
    return spawn("git submodule deinit --all")
end

return git

--[[

]]
