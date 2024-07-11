local spawn = require("src.util.spawn")

---@param program string
---@return Promise<string|nil>
local function which(program)
    local whichcmd = string.format("which %q 2>&1", program)

    return spawn(whichcmd)
        :after(function(res)
            --[[
            if res.exitcode ~= 0 then
                return nil
            end
            ]]

            return res.stdout
        end)
        :after(function(stdout)
            if type(stdout) ~= "string" then
                return nil
            end

            local pattern = string.format("^which: no %s in", program)

            if stdout:match(pattern) then
                return nil
            end

            -- Should just be a path at this point
            stdout = stdout:gsub("\n$", "")

            return stdout
        end)
end

return which
