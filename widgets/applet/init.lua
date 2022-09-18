local relative_import_prefix = (...):match("(.-)[^%.]+$") .. "applet."

local config = require("config")
local gprotected_call = require("gears.protected_call")

local function requireApplet(name)
    -- if config.applet[name] == false, the applet isn't loaded in
    if not config.applet or config.applet[name] ~= false then
        gprotected_call(function()
            require(relative_import_prefix .. name)
        end)
    end
end

requireApplet("calculator")
requireApplet("screenshot")

--[[
    TODO applets should have a class
    TODO that class should allow for dependencies that are checked using awful.spawn.easy_async
    * eg, Screenshot depends on scrot, so isn't enabled until `which scrot` returns exit code 0

    * Hypothetical class
     - applets' actions can be generalized to show, hide, toggle 
        - though more can be added
     - interacts with an internal exitable_dialog seamlessly though helper methods expose the exitable_dialog if needed
     - checks a list of dependencies before allowing the global object
        - use awful.spawn.easy_async and the which command
        - missing dependencies != nil global, just unresponsive methods - hides errors
        - if #self.dependencies == 0, skip the waiting
     - allows me to make applets better, more quickerer
        - changes that bring them closer to clients can be centralized
        - standard applet toolkit (eg, button function that is basically the same between calculator and screenshot)
]]

-- TODO also make the calculator usable
    -- bob don't even have a calculator button

-- TODO some method of adding applets to rofi
    -- might just end up writing my own rofi at this point