local Action   = require("src.util.Action")
local typed    = require("src.util.typed.typed")
local includes = require("src.polyfill.list.includes")

local levels = {
    "trace",
    "debug",
    "info",
    "warn",
    "error",
    "fatal"
}

local LogLevel = Action.create("LogLevel", {
    command = "log-level",
    args = {
        typed.String("info")
    },
})

function LogLevel:on_call(level)
    if level == nil then
        self.log.info(string.format("Current logging level is %s", log.level))

        return
    end

    if not includes(levels, level) then
        self.log.info(string.format("Uknown logging level %q", level))
        
        return
    end
    
    log.level = level

    self.log.info(string.format("Set log level to %s", level))
end

return LogLevel
