
---@param ... LuaX.Props[]
local function merge_props (...)
    local propsets = table.pack(...)

    local props_ret = {}

    for _, props in ipairs(propsets) do
        for k, v in pairs(props) do
            props_ret[k] = v
        end
    end 

    return props_ret
end

return merge_props