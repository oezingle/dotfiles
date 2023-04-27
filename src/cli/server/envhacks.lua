-- setenv and getenv are depreciated, so here's hacks to bring them back

local envhacks = {
    _oldenv = nil
}

--- TODO stack of environments
---@param environment table|nil
function envhacks.setenv(environment)
    if environment then
        envhacks._oldenv = _ENV
        
        _ENV = environment
    else
        _ENV = envhacks._oldenv
    end
end

function envhacks.getenv()
    return _ENV
end

--- Create an environment that overrides only the keys provided
---@param environment table<string, any>
---@return table<string, any> environment for convenience.
function envhacks.overwrite_globals(environment)
    return setmetatable(environment, _G)
end

function envhacks.in_env(environment, callback)
    envhacks.setenv(environment)

    callback()

    envhacks.setenv()
end

return envhacks
