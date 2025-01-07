local package_manager = require("src.util.package_manager")
local Promise         = require("src.polyfill.Promise")
local path_add        = require("src.awesome.core.luarocks.path_add")
local packages        = require("src.awesome.core.luarocks.packages")
local map             = require("src.polyfill.list.map")

local function ensure_rocks()
    path_add()

    return Promise.all(map(packages, function (info)
        return package_manager.rock_install(info)
    end))
end

return ensure_rocks
