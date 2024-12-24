---@generic T
---@param list T[]
---@return T[]
local function list_reverse(list)
    local ret = {}

    local len = #list
    for i=1,len do
        ret[i] = list[len + 1 - i]
    end

    return ret
end

return list_reverse
