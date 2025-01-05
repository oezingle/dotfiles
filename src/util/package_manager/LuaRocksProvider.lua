-- TODO FIXME TODO get back to this file!

local PackageProvider  = require("src.util.package_manager.PackageProvider")
local spawn            = require("src.util.spawn")
local which            = require("src.util.spawn.which")
local Promise          = require("src.polyfill.Promise")
local escape           = require("src.polyfill.string.escape")
local fs               = require("src.util.fs")
local dir              = require("src.util.dir")
local lua_version          = require("src.polyfill.lua_version")

---@class Zingle.Awesome.PackageProvider.LuaRocks : Zingle.Awesome.PackageProvider
---
---@operator call:Zingle.Awesome.PackageProvider.LuaRocks
local LuaRocksProvider = PackageProvider:extend("Zingle.Awesome.PackageProvider.LuaRocks", {
    cache = {
        has = {}
    }
})

LuaRocksProvider.version_arg = "--lua-version=" .. lua_version.version

function LuaRocksProvider:init()
    self.cache = {
        has = {}
    }
end

function LuaRocksProvider.can_use()
    return which("luarocks"):after(function(ret)
        return not not ret
    end)
end

---@param name string
---@param version string?
---@return Promise<Zingle.Awesome.PackageInfo>
function LuaRocksProvider:has(name, version)
    ---@type Promise<Zingle.Awesome.PackageInfo>?
    local p = self.cache.has[name] and Promise.resolve(self.cache.has[name])

    if not p then
        p = Promise.resolve()

        for _, info in ipairs({
            {
                message = "Checking for LuaRock %q as root",
                command = "luarocks show %s %q %s",
            },
            {
                message = "Checking for LuaRock %q locally",
                command = "luarocks show %s --tree generated/luarocks %q %s"
            }
        }) do
            p = p:after(function (has)
                if not has then
                    local exec = string.format(info.command, self.version_arg, name, version or "") .. " 2>&1"

                    log.debug(string.format(info.message, name))
                    log.debug(string.format("Executing: %s", exec))

                    return spawn(exec):after(function (ret)
                        local stdout = ret.stdout

                        if stdout:match("Error: cannot find package") then
                            return false
                        end

                        log.trace("found package", info.message)

                        return stdout
                    end)
                end

                return has
            end)
        end

        -- parse whatever package info we find
        p = p 
            :after(function(out)
                if not out then
                    return { has = false, is_luarock = true }
                end

                local version, description, license, url = out:match("^%s+" ..
                    escape(name) .. "%s*([^%s]+)%s+%-%s+(.-)%s*License:%s+([^\n\r]+)[\n\r]Homepage:%s+([^%s]+)")

                local module, location = out:match("Modules:%s*([^%s]*)%s*%((.-)[/\\][^%./\\]+%.[^%./\\]+%)")

                ---@type {} | Zingle.Awesome.PackageInfo
                local info = {
                    has = true,
                    version_has = version,
                    license = license,
                    url = url,
                    description = description,
                    location = location,
                    install_name = module
                }

                return info
            end)
            :after(function(info)
                -- add to cache
                self.cache.has[name] = info

                return info
            end)
    end

    return p
        :after(function(info)
            ---@type Zingle.Awesome.PackageInfo
            local ret = {
                -- per-call info
                -- TODO FIXME ret.has semver version check
                has = info.has,
                version_wants = version or "any",

                -- trivial entries
                is_luarock = true,
                name = name,

                -- possibly cached values
                install_name = info.install_name,
                version_has = info.version_has,
                license = info.license,
                url = info.url,
                description = info.description,
                location = info.location,
            }

            return ret
        end)
end

---@param package Zingle.Awesome.PackageInfo
---@param force boolean?
---
---@return Promise<boolean, boolean>
function LuaRocksProvider:install(package, force)
    local name = package.name
    local version = package.version_wants

    if self.cache.has[name].has and not force then
        return Promise.resolve(true, false)
    end

    ---@type Promise<boolean>
    local p = force and
        Promise.resolve(false) or
        self:has(name, version):after(function(info)
            return info.has
        end)

    -- Check has cache first
    return p
        :after(function(has)
            if has and not force then
                ---@diagnostic disable-next-line:redundant-return-value
                return true, false
            end

            -- always ensure this dev exists
            fs.mkdir_p(dir.generated.luarocks())

            local p = Promise.resolve()

            for _, info in ipairs({
                {
                    message = "Attempting to install LuaRock %q as root",
                    command = "luarocks install %s %q %s",
                },
                {
                    message = "Attempting to install LuaRock %q locally",
                    command = "luarocks install %s --tree generated/luarocks %q %s"
                }
            }) do
                ---@diagnostic disable-next-line:redundant-parameter
                p = p:after(function (has, installed)
                    if not (has or installed) then
                        local exec = string.format(info.command, self.version_arg, name, version or "") .. " 2>&1"

                        log.info(string.format(info.message, name))
                        log.debug(string.format("Executing: %s", exec))
                                
                        return spawn(exec):after(function (ret)
                            local stdout = ret.stdout

                            local has_error = stdout:match("Error:")

                            if not has_error then
                                ---@diagnostic disable-next-line:redundant-return-value
                                return true, true
                            end

                            ---@diagnostic disable-next-line:redundant-return-value
                            return false, false
                        end)
                    end

                    ---@diagnostic disable-next-line:redundant-return-value
                    return has, installed
                end)
            end

            return p
        end)
end

return LuaRocksProvider
