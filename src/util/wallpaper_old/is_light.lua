local fs = require("src.util.fs")
local spawn = require("src.agnostic.spawn")

local folder_of_this_file = (...):match("(.-)[^%.]+$")

---@module "src.util.wallpaper_old.init"
local wallpaper = require(folder_of_this_file .. "init")

--- Check if a wallpaper is bright
---@param callback fun(is_light: boolean): any
---@param identifier any? the identifier for the wallpaper. defaults to current wallpaper
local function is_light(callback, identifier)
    identifier = identifier or wallpaper.get_current_identifier()

    local dir = fs.directories.wallpaper .. tostring(identifier) .. "/"

    local file = ""
    if not fs.isdir(dir) then
        file = wallpaper.get_current()
    else
        local files = fs.list(dir)

        file = dir .. files[1] 
    end

    spawn(string.format("convert %s -resize 1x1 txt:-", file), function (res)
        local r, g, b = res:match("#([%a%d][%a%d])([%a%d][%a%d])([%a%d][%a%d])")

        local average = (tonumber(r, 16) + tonumber(g, 16) + tonumber(b, 16)) / 3

        local threshold = 128

        local is_light = average > threshold

        callback(is_light)
    end)
end

return is_light
