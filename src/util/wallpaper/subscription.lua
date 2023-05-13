local class = require("lib.30log")
local fs = require("src.util.fs")
local Promise = require("src.util.Promise")

local generate_wallpaper = require("src.util.wallpaper.generate_wallpaper")
local wallpaper = require("src.util.wallpaper.core")

local int = math.floor

---@class Wallpaper.Subscription.Class : Wallpaper.Subscription, LogBaseFunctions
---@operator call:Wallpaper.Subscription.Class
---@field path string
---@field private dimensions { width: number, height: number }
---@field private in_init boolean
---@field auto_generate boolean
local WallpaperSubscription = class("WallpaperSubscription")

---@param callback fun(string)?
---@param width number?
---@param height number?
---@param blur boolean?
---@param identifier string|integer|nil
function WallpaperSubscription:init(callback, width, height, blur, identifier)
    self.in_init = true

    self.auto_generate = true

    self:set_callback(callback)

    self:set_dimensions(width, height)

    self:set_blur(blur)

    self:set_identifier(identifier)

    self.path = fs.directories.assets .. "1x1.png"

    if self.callback then
        self.callback(self.path)
    end

    if awesome then
        awesome.connect_signal("wallpaper_should_change", function()
            self:generate()
        end)
    end

    self.in_init = false

    self:generate()

    return self
end

---@private
---@param key "dimensions"|"blur"|"callback"|"identifier" string
---@param value any
function WallpaperSubscription:change(key, value)
    local old_value = self[key]

    self[key] = value

    if self.in_init or not self.auto_generate then
        return self
    end

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
    width = int(width or 0)
    height = int(height or 0)

    self:change("dimensions", {
        width = width,
        height = height
    })

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

---@return Promise
function WallpaperSubscription:generate()
    local identifier = self.identifier
    local width = self.dimensions.width
    local height = self.dimensions.height
    local blur = self.blur

    if width == nil or width == nil then
        return Promise.resolve()
    end

    ---@type Promise[]
    local promises = {}

    local gen = generate_wallpaper(identifier or wallpaper.current, width, height, blur)
        :after(function(path)
            self.path = path

            return path
        end)
        :after(function(path)
            if self.callback then
                self.callback(path)
            end

            return path
        end)

    table.insert(promises, gen)

    -- Generate all identifiers
    if not identifier then
        for identifier, _ in pairs(wallpaper.config.table) do
            local gen = generate_wallpaper(identifier, width, height, blur)

            table.insert(promises, gen)
        end
    end

    return Promise.all(promises)
end

function WallpaperSubscription:get_path()
    return self.path
end

--- Turn off auto generation, so self:generate() has to be called by the Subscription owner
function WallpaperSubscription:disable_auto_generate()
    self.auto_generate = false

    return self
end

return WallpaperSubscription
