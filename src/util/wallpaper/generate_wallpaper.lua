local fs        = require("src.util.fs")
local spawn     = require("src.agnostic.spawn.promise")
local Promise   = require("src.util.Promise")
local get_path  = require("src.util.wallpaper.get_path")
local wallpaper = require("src.util.wallpaper.core")

local string    = string

--- Generate a wallpaper for a given iterator
---@param identifier string|integer|nil
---@param width number
---@param height number
---@param blur boolean
---@return Promise<string>
local function generate_wallpaper(identifier, width, height, blur)
    if not identifier then
        identifier = wallpaper.current
    end

    local path = get_path(identifier, width, height, blur)

    if not fs.exists(path) then
        ---@type string
        local resize_string = string.format(" -resize %dx%d^ ", width, height)

        ---@type string
        local crop_string = string.format(" -gravity Center -extent %dx%d ", width, height)

        ---@type string
        local blur_string = blur and " -blur 20x20 " or ""

        --[[
            https://imagemagick.org/script/opencl.php

            magick's OpenCL support is limited in this case to the -blur operator, and requires
            that the source code be compiled with OpenCL enabled.
        ]]


        --          enable OpenCL           throttle           1 thread
        ---@type string
        local cmd = "MAGICK_OCL_DEVICE=true MAGICK_THROTTLE=25 MAGICK_THREAD_LIMIT=1 " ..
            "magick convert" ..
            resize_string ..
            crop_string ..
            blur_string .. string.format("'%s' '%s'", wallpaper.config.table[identifier], path)

        return spawn(cmd)
            :after(function()
                return path
            end)
    else
        return Promise.resolve(path)
    end
end

return generate_wallpaper
