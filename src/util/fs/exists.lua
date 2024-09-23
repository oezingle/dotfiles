
local function exists(path)
    local file, _, code = io.open(path, "r")

    if code == 2 then
        return false
    end

    if file then
        file:close()
    end

    return true
end

return exists