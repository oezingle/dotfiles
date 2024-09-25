local Service             = require("src.util.Service")

local enable_gc           = require("src.awesome.core.gc")
local enable_load_scripts = require("src.awesome.core.poll_scripts")
local init_ui             = require("src.awesome.ui")


local function main()
    require("src.awesome.core.error.runtime")

    require("src.awesome.core.layouts")

    -- This line loads services, so we MUST put it before Service.start_all()
    enable_load_scripts()

    Service.log = log
    Service.start_all()

    enable_gc()
    init_ui()
end

return main
