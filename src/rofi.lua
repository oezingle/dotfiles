local awful = require("awful")

local config = require("config")

-- alias calculator="echo 'show_calculator()' | awesome-client"

local function rofi()
	-- not exactly a stellar theme
	-- TODO https://github.com/adi1090x/rofi
	awful.spawn(config.apps.rofi)	
end

return rofi
