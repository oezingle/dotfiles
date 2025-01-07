local path_add        = require("src.awesome.core.luarocks.path_add")
local packages        = require("src.awesome.core.luarocks.packages")
local package_manager = require("src.util.package_manager.package_manager")
local Promise         = require("src.polyfill.Promise")
local reduce          = require("src.polyfill.list.reduce")

---@return Promise<boolean>
local function needs()
    path_add()

    ---@type Promise<boolean>[]
    local promises = {}

    for _, info in pairs(packages) do
        if type(info) == "string" then
            info = { name = info }
        end

        local require_ok = pcall(require, info.install_name or info.name)

        if not require_ok then
            local p = package_manager.rockprovider:has(info.name, info.version_wants)
                :after(function(info)
                    log.warn(string.format("System needs luarock %s", info.name))

                    return not info.has
                end)

            table.insert(promises, p)
        end
    end

    return Promise.all(promises)
        :after(function(result)
            return reduce(result, function(needs_any, promise_res)
                local needs = promise_res[1]

                return needs_any or needs
            end, false)
        end)
end

return needs
