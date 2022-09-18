local awful = require("awful")

-- TODO wibox with ios-style pinned apps, pet rock widget, news widget, with rofi blending into that? custom launcher? probably would be slow but pretty

-- alias calculator="echo 'show_calculator()' | awesome-client"

local function rofi()
	-- not exactly a stellar theme
	-- TODO https://github.com/adi1090x/rofi
	awful.spawn('rofi -modi drun -show drun -show-icons -theme ~/.cache/wal/colors-rofi-dark.rasi')	
end

return rofi
