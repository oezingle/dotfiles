local safe_mode = true

if safe_mode then
    print("Starting awesome in safe mode")
else
    print("Starting awesome")
end

local preload = require("src.awesome.core.preload")

preload(safe_mode)