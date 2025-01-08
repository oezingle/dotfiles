local Service      = require("src.util.Service")
local load_scripts = require("src.awesome.core.load_scripts")
local loader       = require("src.awesome.ui.preload.loader")

local init_ui      = require("src.awesome.ui")

local function main()
    require("src.awesome.core.error.runtime")

    require("src.awesome.core.layouts")

    -- Creates pollers
    load_scripts.reset()
    -- This line loads services, so we MUST put it before Service.start_all()
    load_scripts.poll()

    Service.log = log
    Service.start_all()

    init_ui()

    -- hide loader if it was shown
    loader.stop()
end

return main
