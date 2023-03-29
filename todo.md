
- task bar
	- calendar (click clock)

- rename src.widgets.util.color_bg - src.widgets.util.box?

- improve notification center
	- add date/time

- use 30log for widgets. somehow

- wallpapers
	- partially looks like shit with light wallpaper
		- wal for svg's

- more unit tests

- improve powertop 
	- https://askubuntu.com/questions/678779/powertop-auto-tune-without-messing-with-usb-and-touchpad

- limit hovered clients to 1 while using screen preview
	- should fix mousegrabber issue

- multihead
	- brightness keys / slider control an arbitrary display
	- screen_preview is broken w/ multiple monitors
	- check that all clients show up in client list, as left bar is missing from non-primaries

- break keys out from rc.lua
	- configurable?

- thunar has an error under luajit: attempt to index field 'layout' (a userdata value)

- there sometimes still are ghost appmenu menus
	- seems to happen when you leave and re-enter the same item too quickly
	- clicking an appmenu item doesn't close the menu

- diagnostic / debug features in system menu?

- time doesn't localize

- default app selector (through rofi?)

- configuration interface

- remove dropdown widget

- translations everywhere

- Xorg intel config
	- [disable TearFree, TripleBuffer, SwapbuffersWait](https://wiki.archlinux.org/title/Intel_graphics#Disabling_TearFree,_TripleBuffer,_SwapbuffersWait)

- Optimize
	- https://www.lua.org/gems/sample.pdf
	- http://lua-users.org/wiki/OptimisationTips
	- http://lua-users.org/wiki/OptimisationCodingTips
	- http://lua-users.org/wiki/OptimisingUsingLocalVariables
	- http://lua-users.org/wiki/MinimisingClosures

- cool button library
	- https://github.com/streetturtle/awesome-buttons