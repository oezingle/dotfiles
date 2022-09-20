local time   = require("util.time")
local config = require("config")
local gears  = require("gears")
local gtimer = gears.timer
local gfs    = gears.filesystem
local fs     = require("util.fs")

local config_dir = gfs.get_configuration_dir()

local wallpaper_dir = config_dir .. "cache/wallpaper/"

local read_file = fs.read
local write_file = fs.write
local mkdir = fs.mkdir
local isdir = fs.isdir
local exists = fs.exists

do
    if type(config.wallpaper) == "string" then
        config.wallpaper = { config.wallpaper }
    end
end

-- Regenerate wallpapers if they've changed between awesome restarts
do
    local wallpaper = config.wallpaper

    local last_value = ""

    local wallpaper_is_list = config.wallpaper[1] ~= nil

    -- speed is all we really care about
    if wallpaper_is_list then
        for _, v in ipairs(wallpaper) do
            last_value = last_value .. v
        end
    else
        for k, v in wallpaper do
            last_value = last_value .. k .. v
        end
    end

    local last_values_path = wallpaper_dir .. "last_values"

    if read_file(last_values_path) ~= last_value then
        os.execute("rm -r " .. wallpaper_dir)

        mkdir(wallpaper_dir)

        write_file(last_values_path, last_value)
    end
end

local wallpaper = {}

do
    ---@as string[]|table<string, string>
    wallpaper.table = config.wallpaper

    wallpaper.is_list = wallpaper.table[1] ~= nil

    wallpaper.current_identifier = nil

    local wallpaper_time

    if type(config.wallpaper.time) == "number" then
        -- Set numeric wallpaper times to be in hours

        wallpaper_time = config.wallpaper.time * 60 * 60
    else
        wallpaper_time = config.wallpaper.time
    end

    wallpaper.time = time.parse(
        wallpaper_time or
        time.to_seconds { hour = 1 }
    )

    wallpaper.all_identifiers = function()
        local identifiers = {}

        if wallpaper.is_list then
            for index, _ in ipairs(wallpaper.table) do
                table.insert(identifiers, index)
            end
        else
            for k, _ in wallpaper.table do
                table.insert(identifiers, k)
            end
        end

        return identifiers
    end

    wallpaper.set_current = function()
        if wallpaper.is_list then
            wallpaper.current_identifier = math.random(#wallpaper.table)
        else
            local current_time = time.to_seconds(time.current())

            local best_identifier = nil

            -- TODO 24 hour wraparound -> 24:00 is the closest identifier for 0:00
            for time, _ in wallpaper.table do
                if time.parse(time) < current_time then
                    if not best_identifier or time.parse(time) > time.parse(best_identifier) then
                        best_identifier = time
                    end
                end
            end

            wallpaper.current_identifier = best_identifier
        end

        -- gears.debug.print_warning("Changed wallpaper to " .. tostring(wallpaper.current_identifier))

        awesome.emit_signal("wallpaper_should_change")
    end

    wallpaper.get_current_identifier = function()
        if not wallpaper.current_identifier then
            wallpaper.set_current()
        end

        return wallpaper.current_identifier
    end

    wallpaper.get_current = function()
        if not wallpaper.current_identifier then
            wallpaper.set_current()
        end

        return wallpaper.table[wallpaper.current_identifier]
    end

    require("gears.debug").print_warning(wallpaper.time)

    if #wallpaper.table > 1 then
        wallpaper.timer = gtimer {
            timeout = wallpaper.time,

            autostart = true,

            callback = function()
                wallpaper.set_current()
            end
        }
    end

    wallpaper.set_current()
end

awesome.connect_signal("wallpaper::set_current", function()
    wallpaper.set_current()
end)

--- get the wallpaper at a specific resolution, and with optional blur.
--- saves crazy amounts of time when dealing with widgets (low res images load way faster)
---@param width number?
---@param height number?
---@param blur boolean? default false
---@return string
local function get_wallpaper(width, height, blur)
    if not isdir(wallpaper_dir) then
        mkdir(wallpaper_dir)
    end

    -- Get the default wallpaper
    if not width and not height and not blur then
        return wallpaper.get_current()
    end

    width = math.floor(width or 0)
    height = math.floor(height or 0)

    blur = blur or false

    -- TODO create the current wallpaper first, so the system has something to draw, and then do the rest with an async function or even another thread

    for _, identifier in ipairs(wallpaper.all_identifiers()) do
        local dir = wallpaper_dir .. tostring(identifier) .. "/"

        if not fs.isdir(dir) then
            fs.mkdir(dir)
        end

        -- TOOD create folder by identiifer, save to folder by identifier
        local filename = dir .. tostring(width) .. "x" .. tostring(height) .. (blur and "_blur" or "")

        if not exists(filename) then
            local resize_string = " -resize " .. tostring(width) .. "x" .. tostring(height) .. "^ "

            local crop_string = " -gravity Center -extent " .. tostring(width) .. "x" .. tostring(height) .. " "

            local blur_string = ""

            if blur then
                blur_string = " -blur 20x20 "
            end

            local cmd = "magick convert" ..
                resize_string ..
                crop_string ..
                blur_string .. "'" .. wallpaper.table[identifier] .. "' '" .. filename .. "'"

            os.execute(cmd)
        end
    end

    return wallpaper_dir ..
        tostring(wallpaper.get_current_identifier()) ..
        "/" .. tostring(width) .. "x" .. tostring(height) .. (blur and "_blur" or "")
end

return get_wallpaper
