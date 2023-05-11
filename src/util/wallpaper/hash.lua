
-- local wallpaper = require("src.util.wallpaper")

local tostring = tostring

---@param key string|number
local function hash(key)
    return tostring(key)
end

return hash