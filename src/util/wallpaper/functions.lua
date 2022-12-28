local time   = require("src.util.time")
local config = require("config")
local gtimer = require("gears.timer")

local pairs   = pairs
local ipairs  = ipairs
local table   = table
local math    = math
local awesome = awesome

do
    if type(config.wallpaper) == "string" then
        config.wallpaper = { config.wallpaper }
    end
end

-- check that there is at least 1 wallpaper
assert(next(config.wallpaper))

local folder_of_this_file = (...):match("(.-)[^%.]+$")

---@module "src.util.wallpaper.reset"
require(folder_of_this_file .. "reset")

local wallpaper = {}

local print = require("src.agnostic.print")

do
    ---@type table<string|number, string>
    wallpaper.table = config.wallpaper

    wallpaper.is_list = wallpaper.table[1] ~= nil

    ---@type integer|string|nil
    -- The current identifier. Use wallpaper.get_current_identifier()
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

    local wallpaper_count = #wallpaper.table

    wallpaper.set_current = function()
        if wallpaper.is_list then
            wallpaper.current_identifier = math.random(wallpaper_count)
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

    wallpaper.set_identifier = function (identifier)
        assert(wallpaper.table[identifier] ~= nil)

        wallpaper.current_identifier = identifier

        print("set identifier to " .. tostring(identifier))

        awesome.emit_signal("wallpaper_should_change")
    end

    wallpaper.get_current_identifier = function()
        if not wallpaper.current_identifier then
            wallpaper.set_current()
        end

        return wallpaper.current_identifier
    end

    wallpaper.get_current = function()
        return wallpaper.table[wallpaper.get_current_identifier()]
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

return wallpaper
