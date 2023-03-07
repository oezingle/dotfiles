
return (function()
    local has_awful = pcall(require, "awful")

    if has_awful then
        local spawn = require("awful.spawn")

        ---@param cmd string
        ---@param cb (fun(result: string): nil)?
        return function (cmd, cb)
            if cb then
                return spawn.easy_async_with_shell(cmd, cb)
            else
                return spawn.with_shell(cmd)
            end
        end
    else
        ---@param cmd string
        ---@param cb (fun(result: string): nil)?
        return function(cmd, cb)
            local handle = io.popen(cmd)

            -- stupid luacheck
            if not handle then return end

            local result = handle:read("*a")
            handle:close()

            if cb then
                cb(result)                
            end
        end
    end
end)()
