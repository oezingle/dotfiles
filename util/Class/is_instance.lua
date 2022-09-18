local function is_instance(instance, base)
    if type(instance) == "table" then
        local metatable = getmetatable(instance)

        return metatable and metatable.__index == base        
    else
        return false
    end
end

return is_instance