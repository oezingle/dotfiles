--- TODO FIXME types for utf8
---@type { utf8: unknown, table: tablelib, math: mathlib, string: stringlib }
local locked_libraries = {}

---@param name string
local function lock_library(name)
    local lib = _G[name]

    return setmetatable({}, {
        __index = function(_, k)
            return rawget(lib, k)
        end,
        __newindex = function()
            error(string.format("Cannot add new value to library %s", name))
        end,
        __len = function ()
            return #lib
        end,
        __pairs = function ()
            local iter = pairs(lib)
            return iter
        end,
        __ipairs = function ()
            return ipairs(lib)
        end,
    })
end

for _, name in ipairs({
    "utf8",
    "table",
    "math",
    "string"
}) do
    locked_libraries[name] = lock_library(name)
end

return locked_libraries
