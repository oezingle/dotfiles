
---@alias Zingle.Time.Setter (fun(self: Zingle.Time, value: number): Zingle.Time) | (fun(value: number): Zingle.Time)
---@alias Zingle.Time.Getter fun(self: Zingle.Time): number

---@class Zingle.Time : Log.BaseFunctions
---@field seconds Zingle.Time.Setter
---@field epoch Zingle.Time.Setter
---@field minutes Zingle.Time.Setter
---@field hours Zingle.Time.Setter
---@field days Zingle.Time.Setter
---
---@field toSeconds Zingle.Time.Getter
---@field toEpoch Zingle.Time.Getter
---@field toMinutes Zingle.Time.Getter
---@field toHours Zingle.Time.Getter
---@field toDays Zingle.Time.Getter
---
---@operator call: Zingle.Time
local time = class("Zingle.Time")

function time:init()
    self.v_seconds = 0
    self.v_minutes = 0
    self.v_hours = 0
    self.v_days = 0
end

-- TODO move elsewhere
---@param str string
local function upper_first (str)
    local first = str:sub(1,1)
    local rest = str:sub(2)

    return first:upper() .. rest
end

local units = {
    seconds = 1,
    minutes = 60,
    hours = 60 * 60,
    days = 60 * 60 * 24
}

function time:sum()
    local value = 0
    for name, mult in pairs(units) do
        value = value + (self["v_" .. name] * mult)
    end

    return value
end

for name, mult in pairs(units) do
    time["c_" .. name] = function(input)
        local t = time()

        t[name](t, input)

        return t
    end

    time[name] = function(self, input)
        if type(self) ~= "table" then
            return time["c_" .. name](self)
        end

        self["v_" .. name] = input

        return self
    end

    time["to" .. upper_first(name)] = function (self)
        return self:sum() / mult
    end
end

time.epoch = time.seconds
time.toEpoch = time.toSeconds

return time
