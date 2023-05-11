local fs = require("src.util.fs")
local spawn = require("src.agnostic.spawn.promise")

local wallpaper = require("src.util.wallpaper")

--- Check if a wallpaper is bright
---@param identifier string|integer|nil the identifier for the wallpaper. defaults to current wallpaper
---@return Promise<boolean>
local function is_light(identifier)
    identifier = identifier or wallpaper.current

    local dir = fs.directories.wallpaper .. tostring(identifier) .. "/"

    local file = ""
    if not fs.isdir(dir) then
        file = wallpaper.config.table[identifier]
    else
        local files = fs.list(dir)

        file = dir .. files[1] 
    end

    return spawn(string.format("convert %s -resize 1x1 txt:-", file))
        :after(function (res)
            local r, g, b = res:match("#([%a%d][%a%d])([%a%d][%a%d])([%a%d][%a%d])")
    
            local average = (tonumber(r, 16) + tonumber(g, 16) + tonumber(b, 16)) / 3
    
            local threshold = 128
    
            local is_light = average > threshold
    
            return is_light
        end)
end

return is_light
