
--- run tput command
---@param ... string
local function tput (...) 
    local arg = table.pack("tput", ...)
    local command = table.concat(arg, " ")

    local handle, err = io.popen(command, "r")

    if not handle then
        error(err)
    end

    local res = handle:read("a")

    -- TODO iffy on hardcoding this
    if arg[2] == "lines" or arg[2] == "cols" then
        return tonumber(res:match("%d+"))
    end

    return res
end

return tput