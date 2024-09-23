-- http://lua-users.org/lists/lua-l/2010-06/msg00313.html

local debug = debug

---@param f function|integer
---@return table
---@diagnostic disable-next-line:deprecated
local getfenv = getfenv or function(f)
    f = (type(f) == 'function' and f or debug.getinfo(f + 1, 'f').func)
    local name, val
    local up = 0
    repeat
        up = up + 1
        name, val = debug.getupvalue(f, up)
    until name == '_ENV' or name == nil
    return val
end

return getfenv