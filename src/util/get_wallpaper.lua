local time   = require("src.util.time")
local config = require("config")
local gtimer = require("gears.timer")
local fs     = require("src.util.fs")

local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local os = os
local table = table
local math = math
local awesome = awesome

local wallpaper_dir = fs.dirs.wallpaper

do
    if type(config.wallpaper) == "string" then
        config.wallpaper = { config.wallpaper }
    end
end

-- check that there is at least 1 wallpaper
assert(next(config.wallpaper))

-- Regenerate wallpapers if they've changed between awesome restarts
do
    local wallpaper = config.wallpaper

    local wallpapers = ""

    local wallpaper_is_list = config.wallpaper[1] ~= nil

    -- speed is all we really care about
    if wallpaper_is_list then
        for _, v in ipairs(wallpaper) do
            wallpapers = wallpapers .. v
        end
    else
        for k, v in pairs(wallpaper) do
            if k ~= "time" then
                wallpapers = wallpapers .. k .. v
            end
        end
    end

    local last_values_path = wallpaper_dir .. "last_values"

    if fs.read(last_values_path) ~= wallpapers then
        os.execute("rm -r " .. wallpaper_dir)

        fs.mkdir(wallpaper_dir)

        fs.write(last_values_path, wallpapers)
    end
end

local wallpaper = {}

do
    ---@type table<string|number, string>
    wallpaper.table = config.wallpaper

    wallpaper.is_list = wallpaper.table[1] ~= nil

    ---@type integer|string|nil
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
            for k, _ in pairs(wallpaper.table) do
                if k ~= "time" then
                    table.insert(identifiers, k)
                end
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
            for str_time, _ in pairs(wallpaper.table) do
                if str_time ~= "time" and time.parse(str_time) < current_time then
                    if not best_identifier or time.parse(str_time) > time.parse(best_identifier) then
                        best_identifier = str_time
                    end
                end
            end

            wallpaper.current_identifier = best_identifier
        end

        -- print("Changed wallpaper to " .. tostring(wallpaper.current_identifier))

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

    if not wallpaper.is_list or #wallpaper.table > 1 then
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

local spawn = require("src.agnostic.spawn")

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
        local resize_string = " -resize " .. tostring(width) .. "x" .. tostring(height) .. "^ "

        local crop_string = " -gravity Center -extent " .. tostring(width) .. "x" .. tostring(height) .. " "

        local blur_string = ""

        if blur then
            blur_string = " -blur 20x20 "
        end

        local throttle_string = async_cb and "MAGICK_THROTTLE=50 MAGICK_THREAD_LIMIT=1 " or ""

        local cmd = throttle_string ..
            "magick convert" ..
            resize_string ..
            crop_string ..
            blur_string .. "'" .. wallpaper.table[identifier] .. "' '" .. filename .. "'"

        if async_cb then
            spawn(cmd, function ()
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

--- get the wallpaper at a specific resolution, and with optional blur.
--- saves crazy amounts of time when dealing with widgets (low res images load way faster)
---@param width number?
---@param height number?
---@param blur boolean? default false
---@return string
local function get_wallpaper(width, height, blur)
    if not fs.isdir(wallpaper_dir) then
        fs.mkdir(wallpaper_dir)
    end

    -- Get the default wallpaper
    if not width and not height and not blur then
        return wallpaper.get_current()
    end

    width = math.floor(width or 0)
    height = math.floor(height or 0)

    blur = blur or false

    -- generate the current identifier right now so something can get drawn
    generate_wallpaper(wallpaper.current_identifier, width, height, blur)

    -- generate others
    local iter = list_iter(wallpaper.all_identifiers())

    generate_wallpaper_iter(iter, width, height, blur)

    return wallpaper_dir ..
        tostring(wallpaper.get_current_identifier()) ..
        "/" .. tostring(width) .. "x" .. tostring(height) .. (blur and "_blur" or "")
end

return get_wallpaper
