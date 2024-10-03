
local log = require("lib.log.log")

if false then
    ---@alias Logger.LogFunction fun(...: any)
    
    ---@alias Logger.Level "trace" | "debug" | "info" | "warn" | "error" | "fatal"

    ---@class Logger
    ---@field trace Logger.LogFunction
    ---@field debug Logger.LogFunction
    ---@field info Logger.LogFunction
    ---@field warn Logger.LogFunction
    ---@field error Logger.LogFunction
    ---@field fatal Logger.LogFunction
    ---
    ---@field usecolor boolean
    ---@field logfile string?
    ---@field level Logger.Level
    log = {}
end

return log