
---@generic T
---@param list T[],
---@param elem T|any
---@return false|integer
local function list_includes(list, elem)
    for i, item in ipairs(list) do
        if item == elem then
            return i 
        end
    end

    return false
end

return list_includes