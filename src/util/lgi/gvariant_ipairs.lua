
---@diagnostic disable: undefined-global
local jit = jit or nil

local function gvariant_ipairs(variant)
    if type(jit) == "table" then
        --- Iterate a numerical table
        ---@generic V
        ---@param a V[]
        ---@param i integer
        ---@return integer|nil, V|nil
        local function iter(a, i)
            i = i + 1

            local v = a[i]
            if v then
                return i, v
            end
        end

        return iter, variant, 0
    else
        return ipairs(variant)
    end
end

return gvariant_ipairs
