
- task bar
	- calendar (click clock)

- rename src.widgets.util.color_bg - src.widgets.util.box?

- improve notification center
	- add date/time

- use 30log for widgets. somehow

- applets
	- Network Manager
		- Rebuild as frontend to gnome network apps?

- wallpapers
	- partially looks like shit with light wallpaper
	- wal for svg's

- custom polkit

- more unit tests

- no way to switch audio sink

- Use Promises

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

- notification center doesn't auto close unless you click in it and then out of it

- time doesn't localize

- default app selector (through rofi?)

- wrap configuration in get_config() which does typechecking / makes refactors more easy

- remove dropdown widget

- translation tables

- Xorg intel config
	- [disable TearFree, TripleBuffer, SwapbuffersWait](https://wiki.archlinux.org/title/Intel_graphics#Disabling_TearFree,_TripleBuffer,_SwapbuffersWait)