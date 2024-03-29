-- http://lua-users.org/lists/lua-l/2010-06/msg00313.html

local debug = debug

local envhacks = {}

---@param f function|integer
---@param t table
---@diagnostic disable-next-line:deprecated
envhacks.setfenv = setfenv or function(f, t)
    f = (type(f) == 'function' and f or debug.getinfo(f + 1, 'f').func)
    local name
    local up = 0
    repeat
        up = up + 1
        name = debug.getupvalue(f, up)
    until name == '_ENV' or name == nil
    if name then
        debug.upvaluejoin(f, up, function() return name end, 1) -- use unique upvalue

        debug.setupvalue(f, up, t)
    end
end

---@param f function|integer
---@return table
---@diagnostic disable-next-line:deprecated
envhacks.getfenv = getfenv or function(f)
    f = (type(f) == 'function' and f or debug.getinfo(f + 1, 'f').func)
    local name, val
    local up = 0
    repeat
        up = up + 1
        name, val = debug.getupvalue(f, up)
    until name == '_ENV' or name == nil
    return val
end

return envhacks
