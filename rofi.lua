local awful = require("awful")

-- TODO wibox with ios-style pinned apps, pet rock widget, news widget, with rofi blending into that? custom launcher? probably would be slow but pretty

-- alias calculator="echo 'show_calculator()' | awesome-client"

local check_dependencies = require('util.check_dependencies')

local has_wal = false

-- async fun
check_dependencies({ "wal" }, function ()
	has_wal = true
end)

local function rofi()
	-- not exactly a stellar theme
	-- TODO https://github.com/adi1090x/rofi
	awful.spawn(
		'rofi -modi drun -show drun -show-icons ' .. 
			(has_wal and '-theme ~/.cache/wal/colors-rofi-dark.rasi' or '')
	)	
end

return rofi
