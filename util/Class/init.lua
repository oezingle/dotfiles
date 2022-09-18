
local function class(base)
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