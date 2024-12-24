
-- TODO FIXME TODO get back to this file!

local PackageProvider = require("src.package.PackageProvider")

---@class Zingle.Awesome.PackageProvider.LuaRocks : Zingle.Awesome.PackageProvider
local LuaRocksProvider = PackageProvider:extend("Zingle.Awesome.PackageProvider.LuaRocks")

return LuaRocksProvider