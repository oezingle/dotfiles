
local profiler = require("lib.profiler.src.profiler")

if false then
    ---@class ProfilerConfigurationOverrides 
    ---@field outputFile string? Name of this profiler (to remove itself from reports). default "profiler.lua"
    ---@field emptyToThis string? Rows with no time are set to this value. default "~"
    ---@field fW number? Width of the file column. default 20
    ---@field fnW number? Width of the function name column. default 28
    ---@field lW number? Width of the line column. default 7
    ---@field tW number? Width of the time taken column. default 7
    ---@field rW number? Width of the relative percentage column. default 6
    ---@field cW number? Width of the call count column. default 5
    ---@field reportSaved string? Text for the file output confirmation. default "> Report saved to: "

    profiler = {
        --- Attach a custom function to print profiler messages from_string
        ---@param fn fun (msg: string): nil
        ---@param verbose boolean? default false
        attachPrintFunction = function (fn, verbose) end,

        --- Start profiling
        start = function() end,

        --- Stop profiling
        stop = function () end,

        --- Write the profile report to a file
        ---@param filename string? default 'profiler.log'
        report = function (filename) end,

        --- Modify profiler configuration
        ---@param overrides ProfilerConfigurationOverrides
        configuration = function (overrides) end
    }
end

profiler.configuration({
    outputFile = "lib/profiler/src/profiler.lua"
})

return profiler