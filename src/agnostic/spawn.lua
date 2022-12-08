
return (function()
    local has_awful = pcall(require, "awful")

    if has_awful then
        return require("awful.spawn").easy_async_with_shell
    else
        ---@param cmd string
        ---@param cb fun(result: string): nil
        return function(cmd, cb)
            local handle = io.popen(cmd)

            -- stupid luacheck
            if not handle then return end

            local result = handle:read("*a")
            handle:close()

            cb(result)
        end
    end
end)()
