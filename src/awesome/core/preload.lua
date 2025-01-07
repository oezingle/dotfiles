local fatal_error = require("src.awesome.core.error.fatal_error")

---@diagnostic disable-next-line:lowercase-global
log = { debug = print, info = print }

local function preload_git()
    -- spawn.init might not work correctly here.
    local ok = pcall(require, "src.util.spawn.spawn")

    local default_loaded = {}

    -- setup shim 'packages'
    if not ok then
        for k, v in pairs(package.loaded) do
            default_loaded[k] = v
        end

        -- gross minimal 30log shim
        package.loaded["lib.30log"] = function(name, clazz)
            return setmetatable(clazz or {}, {
                __call = function(t, ...)
                    local instance = setmetatable({ class = t }, { __index = t })

                    instance:init()

                    return instance
                end
            })
        end
    end

    local loader = require("src.awesome.ui.preload.loader")
    local git = require("src.util.spawn.git")

    -- tear down shims
    if not ok then
        package.loaded = default_loaded
    end

    return git.submodules_needs()
        :after(function(modules)
            if #modules ~= 0 then
                log.info("Installing submodules")

                loader.start("Installing dependencies for you")

                return git.submodules_init()
            end
        end)
end

-- Automatically install LuaRocks
---@return Promise<nil>
local function preload_luarocks()
    log.debug("preload_luarocks")

    local loader = require("src.awesome.ui.preload.loader")
    local luarocks = require("src.awesome.core.luarocks")

    return luarocks.needs()
        :after(function(needs)
            if needs then
                log.info("Installing LuaRocks")

                loader.start("Installing dependencies for you")

                return luarocks.ensure()
            end
        end)
        :after(function()
            log.debug("Dependency checks done")
        end)
end

---@param safe boolean
local function preload(safe)
    preload_git()
        :after(function()
            -- assert 30log isn't my gross shim for Promises, as they are the only class already loaded.
            local Promise = require("src.polyfill.Promise")
            assert(tostring(Promise):match("Promise"), "Promise relies on shimmed class")
        end)
        :after(function()
            log.debug("loading amenities")

            require("src.amenities.init")
        end)
        :after(preload_luarocks)
        :after(function()
            local load_main = function()
                local main = require("src.awesome.core.main")

                main()
            end

            if safe then
                xpcall(load_main, function(err)
                    local message = debug.traceback(err)

                    fatal_error(message)
                end)
            else
                load_main()
            end
        end)
        :catch(function(err)
            fatal_error(err)
        end)
end

return preload
