
local version = {}

---@alias LuaVersion "5.4"|"5.3"|"5.2"|"5.1"|"5.0"|"4.0"|"3.2"|"3.1"|"3.0"|"2.5"|"2.4"|"2.3"|"2.2"|"2.1"|"1.1"|"1.0"|string

---@return string api_version, boolean jit
function version.get()
    local version_string = _VERSION:match("%d%.%d$")

    local has_jit = false

    if jit then
        has_jit = true
    end

    return version_string, has_jit
end

--- Only run the callback if the version requirements are satisfied
---@param api_version LuaVersion an API version. 
---@param needs_jit boolean|nil true for LuaJit, false for PUC Lua, nil for either
---@param callback function
function version.require(api_version, needs_jit, callback)
    local version, has_jit = version.get()

    if version == api_version then
        if needs_jit == nil or needs_jit == has_jit then
            callback()
        end
    end
end

--- Throw an error if the version requirements are not satisfied
---@param api_version LuaVersion an API version. 
---@param needs_jit boolean|nil true for LuaJit, false for PUC Lua, nil for either
function version.assert(api_version, needs_jit)
    local version, has_jit = version.get()

    assert(version == api_version)

    assert(needs_jit == nil or needs_jit == has_jit)
end

return version