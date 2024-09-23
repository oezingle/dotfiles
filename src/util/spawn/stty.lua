-- TODO currently ununsed but could be implemented into BasicPrompt

-- http://lua-users.org/lists/lua-l/2012-09/msg00360.html
---@param ... string
local function stty(...)
    local args = table.pack(...)
    
    local ok, p = pcall(io.popen, "stty -g")

    if not ok or not p then return nil end

    local state = p:read()
    p:close()

    if state and #args > 0 then
        os.execute(table.concat({ "stty", ... }, " "))
    end

    return state
end

return stty