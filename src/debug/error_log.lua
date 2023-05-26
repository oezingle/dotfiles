
-- TODO set upper limit for crash log count

local fs = require("src.util.fs")

local cache_dir = require("src.util.fs.directories").cache

local error_dir = cache_dir .. "error/"

-- ensure error_dir exists
do
    if not fs.exists(error_dir) or not fs.isdir(error_dir) then        
        fs.mkdir(error_dir)
    end
end

local time = require("src.util.time")

local function error_log(message, startup)
    if startup then
        message = "==== ENCOUNTERED DURING STARTUP ====\n" .. message
    end

    fs.write(error_dir .. "report_" .. time.utc() .. ".txt", message)
end

if awesome.startup_errors then
    error_log(awesome.startup_errors, true)
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        error_log(debug.traceback(tostring(err)))

        in_error = false
    end)
end