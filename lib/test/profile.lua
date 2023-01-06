--- Print how long a function takes in ms
---@param callback function
---@param name string?
---@param silent boolean?
local function profile(callback, name, silent)
    name = name or "?"

    silent = silent or false

    local start = os.clock()

    collectgarbage("collect")
    collectgarbage("stop")

    local mem_start = collectgarbage("count")

    callback()

    local mem_difference = math.floor(collectgarbage("count") - mem_start)

    collectgarbage("restart")
    collectgarbage("collect")

    local mem_final = math.floor(collectgarbage("count") - mem_start)

    local time_difference = os.clock() - start

    local milliseconds = math.floor(time_difference * 1000)

    if not silent then
        print(name ..
            " took " ..
            milliseconds .. "ms and " .. mem_difference .. "KB of memory, resulting in " .. mem_final .. "KB allocated")
    end

    return {
        ms = milliseconds,
        us = math.floor(time_difference * 1000 * 1000),
        mem_used = mem_difference,
        mem_allocated = mem_final
    }
end

return profile
