require("src.amenities.init")

local main = require("src.awesome.core")

local error_page = require("src.awesome.core.error.page")

local NO_RESTART = true

if NO_RESTART then
    xpcall(main, function (err)
        local message = debug.traceback(err)

        error_page.display(message)
    end)
else
    main()
end
