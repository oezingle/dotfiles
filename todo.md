
- hotkeys to move/resize floating clients

- task bar
	- calendar (click clock)

- firefox PiP 
	- isn't draggable

- remake older widgets - they're full of obtuse helpers and not optimal 
	- color_bg_widget
	- the way music updates

- pet rock widget

- improve notification center
	- scroll is broken
	- kinda boring idk
	- add date/time
	- add DnD

- rofi theme
	- a templating engine: follow config.popup colors?
	- see http://olivinelabs.com/lustache/

- use 30log for widgets. somehow

- applets
	- math symbols applet
	- Network Manager: WPA/WPA2 enterprise networks
		- conflicting design languages
			- lower radius on network-manager
			- network-manager util should live as an applet
	- finish calculator
	- emoji selector

- wallpapers
	- looks like shit with light wallpaper
	- use wal for font colors, and dynamic icons

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

- hover titlebar buttons

- figure out why tf appmenus don't work on awesome-luajit

- break keys out from rc.lua
	- configurable?

- hot reloading? perchance?
	- https://github.com/anton-kl/lua-hot-reload

- restore layouts / windows
	- save/load JSON with lib/json

- store color from src.taskbar.battery / src.widgets.components.switch somewhere smart

- hide music widget if playerctl isn't installed