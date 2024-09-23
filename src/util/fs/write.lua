
---@param path string
---@param contents string
local function write(path, contents)
    if path == nil then
        error(string.format("path is nil"))
    end

    local file = io.open(path, "w")

    if not file then
        error(string.format("Unable to open file %q for writing", path))
    end

    file:write(contents)

    file:flush()
    file:close()
end

return write