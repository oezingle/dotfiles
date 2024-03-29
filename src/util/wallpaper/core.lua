local config = require("config")

local time = require("src.util.time")

local reset_if_needed = require("src.util.wallpaper.reset")

local math = math

---@alias Wallpaper.Config { time: string, table: string[]|table<string, string>, is_list: boolean }

---@class Wallpaper.Subscription
---@field width number
---@field height number
---@field blur boolean
---@field identifier string|integer|nil
---@field callback fun(string)

---@return Wallpaper.Config
local function get_wallpaper_config()
    local table = config.wallpaper.list

    if type(table) == "string" then
        table = { table }
    end

    local is_list = table[1] ~= nil

    local time_string = config.wallpaper.time or "1:00"

    return {
        time    = time.parse(time_string),
        table   = table,
        is_list = is_list
    }
end

---@type { config: Wallpaper.Config, current: string|integer|any, subscriptions: Wallpaper.Subscription[] }
local wallpaper = {
    config = get_wallpaper_config(),

    current = nil,

    subscriptions = {}
}

function wallpaper._set_list_current()
    wallpaper.current = math.random(#wallpaper.config.table)
end

function wallpaper._set_time_current()
    local current_time = time.to_seconds(time.current())

    local best_identifier = nil

    -- TODO 24 hour wraparound -> 24:00 is the closest identifier for 0:00
    for str_time, _ in pairs(wallpaper.config.table) do
        if str_time ~= "time" and time.parse(str_time) < current_time then
            if not best_identifier or time.parse(str_time) > time.parse(best_identifier) then
                best_identifier = str_time
            end
        end
    end

    wallpaper.current = best_identifier
end

--- Get the path of the current wallpaper
function wallpaper.get_current()
    return wallpaper.config.table[wallpaper.current]
end

---@param identifier any?
function wallpaper.set_current(identifier)
    if identifier then
        wallpaper.current = identifier
    else
        if wallpaper.config.is_list then
            wallpaper._set_list_current()
        else
            wallpaper._set_time_current()
        end
    end

    if awesome then
        awesome.emit_signal("wallpaper_should_change")
    end
end

--- A slow method to get all identifiers
---@return (string|integer)[]
function wallpaper.identifiers()
    local identifiers = {}

    for k, _ in pairs(wallpaper.config.table) do
        table.insert(identifiers, k)
    end

    return identifiers
end

-- TODO create timer if awesome

reset_if_needed(wallpaper.config)

wallpaper.set_current()

if awesome then
    local start_wallpaper_timer = require("src.util.wallpaper.timer")

    start_wallpaper_timer(wallpaper.config, wallpaper.set_current)
    
    awesome.connect_signal("wallpaper::set_current", function()
        wallpaper.set_current()
    end)
end

return wallpaper
