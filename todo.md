
- task bar
	- calendar (click clock)

- remake older widgets - they're full of obtuse helpers and not optimal 
	- color_bg_widget

- improve notification center
	- add date/time

- use 30log for widgets. somehow

- applets
	- Network Manager
		- Rebuild as frontend to gnome network apps?
	- emoji selector

- wallpapers
	- looks like shit with light wallpaper

- custom polkit

- more unit tests

- improve battery widget
	 - click for applet w/ powertop-like stats

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

- store color from src.taskbar.battery / src.widgets.components.switch somewhere smart

- thunar has an error under luajit: attempt to index field 'layout' (a userdata value)

- there sometimes still are ghost appmenu menus
	- seems to happen when you leave and re-enter the same item too quickly

- profiling

- diagnostic / debug menu?

- notification center doesn't auto close unless you click in it and then out of it

- time doesn't localize

- default app selector (through rofi?)

- use fs.json.load()

- switch to fs.directories everywhere

- wrap configuration in get_config() which does typechecking / makes refactors more easy

- remove dropdown widget