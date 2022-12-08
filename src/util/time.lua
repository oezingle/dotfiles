local testable = require("src.util.testable")

local time = {}

---@class simpledate
---@field hour number|nil
---@field min number|nil
---@field sec number|nil

---@return simpledate
function time.current()
    local current = os.date("*t")

    return {
        hour = current.hour,
        min = current.min
    }
end

---@param str string
---@return simpledate
function time.from_string(str)
    assert(string.match(str, "%d+:%d"))

    local numbers = {}

    for number_s in string.gmatch(str, "%d+") do
        table.insert(numbers, tonumber(number_s))
    end

    return {
        hour = numbers[1],
        min = numbers[2]
    }
end

---@param date simpledate
---@return number
function time.to_seconds(date)
    -- quicker than os.date(os.time(osdate))
    local hour = date.hour or 0
    local min = date.min or 0
    local sec = date.sec or 0

    return ((hour * 60) + min) * 60 + sec
end

---@param anything string|number|table
---@return number|nil
function time.parse(anything)
    if type(anything) == "string" then
        return time.to_seconds(time.from_string(anything))
    elseif type(anything) == "number" then
        return anything
    elseif type(anything) == "table" then
        return time.to_seconds(anything)
    end
end

return testable(time, {
    testable.assert(function()
        return time.current().hour == os.date("*t").hour
    end, "Current Hour"),
    testable.assert(function()
        return time.from_string("18:30").min == 30
    end, "Time Parsing"),
    testable.assert(function()
        return time.to_seconds(time.from_string("1:30")) == 90 * 60
    end, "To Seconds"),
})
