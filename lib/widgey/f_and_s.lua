
local f_and_s = {}

--- Turn a function into a string
---@param fn function|string
---@param nostrip boolean?
function f_and_s.ftos(fn, nostrip)
    nostrip = nostrip or false

    if type(fn) == "string" then
        return fn
    end

    local str = string.format("load(%q)", string.dump(fn, not nostrip))

    return str
end

--- Turn a string into a function
---@param str string|function
---@param chunkname string?
---@param env table?
function f_and_s.stof(str, chunkname, env)
    if type(str) == "function" then
        return str
    end

    local fn, err = load("return " .. str, chunkname, nil, env)

    if fn then
        return fn()
    else
        error(err)
    end
end

return f_and_s