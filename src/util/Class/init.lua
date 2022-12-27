
--- Bind base.new to base.__call
---@generic T : table
---@param base T?
---@return T
---@deprecated
local function class(base)
    base = base or {}

    setmetatable(base, {
        __call = function(_, ...)
            local instance = {}

            setmetatable(instance, { __index = base })

            return base.init(instance, ...)
        end
    })

    return base
end

return class
