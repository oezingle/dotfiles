local Promise = require("src.polyfill.Promise")

local LuaRocksProvider = require("src.package.LuaRocksProvider")

--- TODO FIXME should deal with naming convention issues here - package is a global in lua already!
---@class Zingle.Awesome.PackageLib
---@field info fun(name: string, version: string?): Promise<Zingle.Awesome.PackageInfo>
---@field install fun(packageinfo: Zingle.Awesome.PackageInfo): Promise<boolean>
local packagelib = {}

---@type Zingle.Awesome.PackageProvider
packagelib.provider = nil

packagelib.rockprovider = LuaRocksProvider()

---@class Zingle.Awesome.PackageInfo
---@field has boolean
---@field version_has string?
---@field version_wants string?
---@field is_luarock boolean
---@field name string
---@field install_name string

---@param name string
---@param version string?
---@return Promise<Zingle.Awesome.PackageInfo>
function packagelib.info(name, version)
    version = version or "any"
    local install_name = packagelib.provider:translate(name)

    local info = packagelib.provider:has(install_name, version)

    return Promise:resolve(info)
        ---@param info Zingle.Awesome.PackageInfo
        :after(function(info)
            info.name = name
        end)
end

---@param packageinfo Zingle.Awesome.PackageInfo
function packagelib.install(packageinfo)
    return packagelib.provider:install(packageinfo)
        :after(function(ok)
            if not ok then
                -- TODO FIXME notify_warn
                error("oh man")
            end
        end)
end

--[[
---@param name string
---@param version string?
---@return Promise<Zingle.Awesome.PackageInfo>
function packagelib.luarock(name, version)
    version = version or "any"
    name = packagelib.provider:
end
]]

return packagelib
