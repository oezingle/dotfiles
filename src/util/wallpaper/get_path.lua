
local fs = require("src.util.fs")

local hash = require("src.util.wallpaper.hash")

---@param key any
---@param width any
---@param height any
---@param blur any
---@return string
local function get_path(key, width, height, blur)
    local dir = fs.directories.wallpaper .. hash(key) .. "/"

    if not fs.isdir(dir) then
        fs.mkdir(dir)
    end

    return dir .. tostring(width) .. "x" .. tostring(height) .. (blur and "_blur" or "")
end

return get_path