require("src.util.spawn.git").init_submodules()
require("src.amenities.init")

local ensure_rocks = require("src.awesome.core.ensure_rocks")
local Promise      = require("src.polyfill.Promise")

local error_page = require("src.awesome.core.error.page")

local safe_mode = true

if safe_mode then
    Promise.resolve()
        :after(ensure_rocks)
        :after(function ()
            xpcall(function()
                local main = require("src.awesome.core")
        
                main()
            end, function(err)
                local message = debug.traceback(err)
        
                error_page.display(message)
            end)        
        end)
else
    local main = require("src.awesome.core")

    main()
end
