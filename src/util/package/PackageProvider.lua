
---@class Zingle.Awesome.PackageProvider : Log.BaseFunctions
---@field can_use fun(): boolean | Promise<boolean>
---@field has fun(self: self, name: string, version: string): Zingle.Awesome.PackageInfo | Promise<Zingle.Awesome.PackageInfo>
---@field install fun(self: self, package: Zingle.Awesome.PackageInfo): Promise<boolean> Install a given package
---@field protected translations table<string, string>
---@field translate fun(self: self, name: string): string
local PackageProvider = class("Zingle.Awesome.Package.PackageProvider")
PackageProvider.translations = {}

function PackageProvider.can_use ()
    return false
end

function PackageProvider:has ()
    return { has = false }
end

--- Translate the package name as the dotfiles know it to a distribution specific package name
function PackageProvider:translate (package)
    return self.translations[package] or package
end

return PackageProvider