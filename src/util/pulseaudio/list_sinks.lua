local spawn = require("src.agnostic.spawn")

---@enum PulseSinkState
local pulseSinkState = {
    SUSPENDED = "SUSPENDED",
    RUNNING   = "RUNNING"
}

---@alias PulseSink { index: number, id: string, driver: string, sample_specification: string, state: PulseSinkState }

---@param callback fun(sinks: PulseSink[])
local function list_sinks(callback)
    spawn("pactl list short sinks", function(result)
        local sinks = {}

        for index_s, id, driver, sample_specification, state in result:gmatch("(%d+)%s+([^%s]+)%s+([^%s]+)%s+([^	]+)%s+(%a+)") do
            local index = tonumber(index_s)

            sinks[index + 1] = {
                index                = index,
                id                   = id,
                driver               = driver,
                sample_specification = sample_specification,
                state                = state
            }
        end

        callback(sinks)
    end)
end

return list_sinks
