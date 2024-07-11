
--- TODO FIXME does io.popen include a newline? awful.easy_async_with_shell does!
---@param cmd string
---@return string
local function spawn_vanilla_sync(cmd)
    local handle = io.popen(cmd)

    -- stupid luacheck
    if not handle then 
        error("unable to popen")
    end

    local result = handle:read("*a")
    handle:close()

    return result
end

return spawn_vanilla_sync
