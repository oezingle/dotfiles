local fs = require("src.util.fs")
local spawn = require("src.agnostic.spawn")

local folder_of_this_file = (...):match("(.-)[^%.]+$")

---@module "src.util.wallpaper.init"
local wallpaper = require(folder_of_this_file .. "init")

local wallpaper_dir = fs.directories.wallpaper
--- Generate a wallpaper for a given iterator
---@param identifier any
---@param width number
---@param height number
---@param blur boolean
---@param async_cb function?
local function generate_wallpaper(identifier, width, height, blur, async_cb)
    async_cb = async_cb or nil

    local dir = wallpaper_dir .. tostring(identifier) .. "/"

    if not fs.isdir(dir) then
        fs.mkdir(dir)
    end

    local filename = dir .. tostring(width) .. "x" .. tostring(height) .. (blur and "_blur" or "")

    if not fs.exists(filename) then
        ---@type string
        local resize_string = " -resize " .. tostring(width) .. "x" .. tostring(height) .. "^ "

        ---@type string
        local crop_string = " -gravity Center -extent " .. tostring(width) .. "x" .. tostring(height) .. " "

        ---@type string
        local blur_string = blur and " -blur 20x20 " or ""

        ---@type string
        local throttle_string = async_cb and "MAGICK_THROTTLE=50 MAGICK_THREAD_LIMIT=1 " or ""

        ---@type string
        local cmd = throttle_string ..
            "magick convert" ..
            resize_string ..
            crop_string ..
            blur_string .. "'" .. wallpaper.table[identifier] .. "' '" .. filename .. "'"

        if async_cb then
            spawn(cmd, function()
                async_cb()
            end)
        else
            os.execute(cmd)
        end
    else
        -- callback for wallpapers that already exist
        if async_cb then
            async_cb()
        end
    end
end

--- Generate wallpapers asyncronously with an iterator function
---@param iter function an iterator
---@param width number
---@param height number
---@param blur boolean
local function generate_wallpaper_iter(iter, width, height, blur)
    local identifier = iter()

    if not identifier then
        return
    end

    -- recursive call
    generate_wallpaper(identifier, width, height, blur, function()
        generate_wallpaper_iter(iter, width, height, blur)
    end)
end

local function list_iter(t)
    local i = 0
    local n = #t
    return function()
        i = i + 1
        if i <= n then return t[i] end
    end
end

return {
    generate_wallpaper = generate_wallpaper,
    generate_wallpaper_iter = generate_wallpaper_iter,
    list_iter = list_iter
}