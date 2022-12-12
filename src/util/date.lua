local IS_24H = false

-- 24 hours isn't a super precise metric, but is close enough
local one_day = 24 * 60 * 60

--- Format a integer time or osdate into a human-readable xx:xx time. includes AM/PM in 12 hour mode
---@param time_or_date integer|osdate
---@return string
local function format_time(time_or_date)
    -- cast input argument to an osdate
    local date = type(time_or_date) == "number" and os.date("*t", time_or_date) or time_or_date

    local formatted_hour = IS_24H and
        date.hour or
        (function()
            local hour = tonumber(date.hour)

            return hour > 12 and hour - 12 or hour
        end)()

    return tostring(formatted_hour) .. ":" .. string.format("%02d", date.min) ..
        (IS_24H and "" or (date.hour > 12 and " PM" or " AM"))
end

--- Format a time nicely for the notificaiton center
---@param time integer|nil
---@return string formatted_date
local function format_date(time)
    if not time then
        time = os.time()
    end

    local current_time = os.time()

    ---@type osdate
    local time_as_date = os.date("*t", time) --[[@as osdate]]

    local today = os.time { day = time_as_date.day, year = time_as_date.year, month = time_as_date.month }

    if today >= current_time - one_day then
        return "Today, " .. format_time(time)
    elseif today >= current_time - (2 * one_day) then
        return "Yesterday, " .. format_time(time)
    elseif today >= current_time - (7 * one_day) then
        return ({
            [1] = "Sunday",
            [2] = "Monday",
            [3] = "Tuesday",
            [4] = "Wednesday",
            [5] = "Thursday",
            [6] = "Friday",
            [7] = "Saturday"
        })[time_as_date.wday]
    else
        return string.format("%02d", time_as_date.day) ..
            "/" .. string.format("%02d", time_as_date.month) .. "/" .. string.format("%02d", time_as_date.year)
    end
end

return {
    format = format_date
}