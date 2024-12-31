require("src.util.spawn.git").init_submodules()

os.exit(1)

require("src.amenities.init")

local error_page = require("src.awesome.core.error.page")

local safe_mode = true

if safe_mode then
    xpcall(function ()
        local main = require("src.awesome.core")

        main()
    end, function (err)
        local message = debug.traceback(err)

        error_page.display(message)
    end)
else
    local main = require("src.awesome.core")

    main()
end
