local relative_import_prefix = (...):match("(.-)[^%.]+$") .. "applet."

local config = require("config")
local gprotected_call = require("gears.protected_call")

local function require_applet(name)
    -- if config.applet[name] == false, the applet isn't loaded in
    if not config.applet or config.applet[name] ~= false then
        gprotected_call(function()
            require(relative_import_prefix .. name)
        end)
    end
end

require_applet("choose_wallpaper")
require_applet("emoji_selector")
require_applet("system_info")
require_applet("calculator")
require_applet("screenshot")

-- TODO also make the calculator usable
    -- bob don't even have a calculator button

-- TODO some method of adding applets to rofi