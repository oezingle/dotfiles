local fs = require("src.util.fs")
local wallpaper_dir = fs.directories.wallpaper

local folder_of_this_file = (...):match("(.-)[^%.]+$")

---@module "src.util.wallpaper.init"
local wallpaper = require(folder_of_this_file .. "init")

---@module "src.util.wallpaper.generate_wallpaper"
local generate_lib = require(folder_of_this_file .. "generate_wallpaper")

local generate_wallpaper = generate_lib.generate_wallpaper
local generate_wallpaper_iter = generate_lib.generate_wallpaper_iter
local list_iter = generate_lib.list_iter

--- get the wallpaper at a specific resolution, and with optional blur.
--- saves crazy amounts of time when dealing with widgets (low res images load way faster)
---@param width number?
---@param height number?
---@param blur boolean? default false
---@param identifier any? optionally provide an identifier. If nil, wallpaper.get_current_identifier() is used
---@return string
local function get_wallpaper(width, height, blur, identifier)
    if not fs.isdir(wallpaper_dir) then
        fs.mkdir(wallpaper_dir)
    end

    -- Get the default wallpaper
    if not width and not height and not blur and not identifier then
        return wallpaper.get_current()
    end

    width = math.floor(width or 0)
    height = math.floor(height or 0)

    blur = blur or false

    identifier = identifier or wallpaper.get_current_identifier()

    -- generate the current identifier right now so something can get drawn
    generate_wallpaper(identifier, width, height, blur)

    -- generate others
    local iter = list_iter(wallpaper.all_identifiers())

    generate_wallpaper_iter(iter, width, height, blur)

    return wallpaper_dir ..
        tostring(identifier) ..
        "/" .. tostring(width) .. "x" .. tostring(height) .. (blur and "_blur" or "")
end

return get_wallpaper
