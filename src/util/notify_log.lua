require("src.amenities.init")

local configuration = require("src.configuration")
local reduce        = require("src.polyfill.list.reduce")


local log_levels = {
    "trace",
    "debug",
    "info",
    "warn",
    "error",
    "fatal",
}

---@type { ["trace"|"debug"|"info"|"warn"|"error"|"fatal"]: true }
local is_logger  = reduce(log_levels, function(obj, mode, index)
    obj[mode] = index

    return obj
end, {})

local notify_log = {
    level = "fatal"
}

configuration:on_change(function(info)
    local config = info.configuration

    local log_level = config.notify.log.level

    notify_log.level = log_level
end)

---@param message any
---@param level any
function notify_log.notify (message, level)
    -- TODO this shit lmfao
end

---@return string message
function notify_log.stringify (...)
    local ret = {}

    for _, item in ipairs(table.pack(...)) do
        table.insert(ret, tostring(item))
    end

    return table.concat(ret, "\t")
end

---@param level string
function notify_log.should_notify (level)
    return is_logger[level] and is_logger[level] >= is_logger[notify_log.level]
end

function notify_log.index(t, key)
    if notify_log.should_notify(key) then
        return function (...)
            notify_log.notify(notify_log.stringify(...), key)

            t[key](...)
        end
    end

    return t[key]
end

function notify_log.register ()
    setmetatable(log, {
        __index = notify_log.index
    })
end

return notify_log