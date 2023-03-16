
--[[
    I don't return an anonymous function here because lua performance reccomendations are to minimize closures.
    Code legibility is only marginally decreased by including the function itself as the first argument,
    runtime speed is equal or better, and no new memory is allocated just to be discarded. win.
]]

--- Wrap a function that returns (value) or (nil, err) to lua's error()
---@param cb function the callback to fire
---@param ... any arguments for the callback
---@return any
local function native_error(cb, ...)
    local value, err = cb(...)

    if err then
        error(err)
    end

    return value
end

return native_error