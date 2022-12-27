
- task bar
	- calendar (click clock)

- remake older widgets - they're full of obtuse helpers and not optimal 
	- color_bg_widget

- improve notification center
	- add date/time

- use 30log for widgets. somehow

- applets
	- Network Manager
		- WPA/WPA2 enterprise networks
		- conflicting design languages
			- lower radius on network-manager
			- network-manager util should live as an applet
		- Rebuild as frontend to gnome network apps?
	- finish calculator
	- emoji selector

- wallpapers
	- looks like shit with light wallpaper

- custom polkit

- more unit tests

- improve battery widget
	 - click for applet w/ powertop-like stats

- fun button to change wallpaper
	- maybe even select?

- set `inode/directory` mimetype to use thunar over VS Code 

- no way to switch audio sink

- Use Promises

- limit hovered clients to 1 while using screen preview
	- should fix mousegrabber issue

- multihead
	- brightness keys / control center controls an arbitrary display
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

- ignore output from xfce4-power-manager etc

- notification center doesn't auto close unless you click in it and then out of it