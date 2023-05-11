local class = require("lib.30log")
local fs = require("src.util.fs")
local generate_wallpaper = require("src.util.wallpaper.generate_wallpaper")
local wallpaper = require("src.util.wallpaper.core")

---@class Wallpaper.Subscription.Class : Wallpaper.Subscription, LogBaseFunctions
---@operator call:Wallpaper.Subscription.Class
---@field path string
local WallpaperSubscription = class("WallpaperSubscription")

---@param callback fun(string)?
---@param width number?
---@param height number?
---@param blur boolean?
---@param identifier string|number|nil
function WallpaperSubscription:init(callback, width, height, blur, identifier)
    self:set_callback(callback)

    self:set_dimensions(width, height)

    self:set_blur(blur)

    self:set_identifier(identifier)

    self.path = fs.directories.assets .. "1x1.png"

    if self.callback then
        self.callback(self.path)
    end
end

---@private
---@param key "width"|"height"|"blur"|"callback"|"identifier" string
---@param value any
function WallpaperSubscription:change(key, value)
    local old_value = self[key]

    self[key] = value

    if value ~= old_value then
        self:generate()
    end

    return self
end

---@param callback fun(string)?
function WallpaperSubscription:set_callback(callback)
    self:change("callback", callback)

    return self
end

---@param width number?
---@param height number?
function WallpaperSubscription:set_dimensions(width, height)
    width, height = width or 0, height or 0

    self:change("width", width)
    self:change("height", height)

    return self
end

function WallpaperSubscription:set_blur(blur)
    blur = blur or false

    self:change("blur", blur)

    return self
end

function WallpaperSubscription:set_identifier(identifier)
    self:change("identifier", identifier)

    return self
end

function WallpaperSubscription:generate()
    local identifier = self.identifier
    local width = self.width
    local height = self.height
    local blur = self.blur

    generate_wallpaper(identifier, width, height, blur)
        :after(function(path)
            self.path = path

            return path
        end)
        :after(function(path)
            if self.callback then
                self.callback(path)
            end
        end)

    -- Generate all identifiers
    if not identifier then
        for identifier, _ in pairs(wallpaper.config.table) do
            generate_wallpaper(identifier, width, height, blur)
        end
    end
end

function WallpaperSubscription:get_path()
    return self.path
end

return WallpaperSubscription
