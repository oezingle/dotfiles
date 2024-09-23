
---@param path string
---@return string
---@nodiscard
local function read (path)
    if path == nil then
        error(string.format("path is nil"))
    end

    local file = io.open(path, "r")

    if not file then
        error(string.format("Unable to open file %q for reading", path))
    end

    return file:read("a")
end

return read