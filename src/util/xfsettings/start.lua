local pidwatch = require "src.sh.pidwatch"

local function start_xfsettings ()
    pidwatch("xfsettingsd")
end