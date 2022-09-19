
--- Bind base.new to base.__call
---@param base table?
local function class(base)
    base = base or {}

    setmetatable(base, {
        __call = function(_, ...)
            local instance = {}

            setmetatable(instance, { __index = base })

            return base.new(instance, ...)
        end
    })

    return base
end

return class
