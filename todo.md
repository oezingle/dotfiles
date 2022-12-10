
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

- rofi theme
	- a templating engine: follow config.popup colors?
	- see http://olivinelabs.com/lustache/

- use 30log for oop

- applets
	- math symbols applet
	- Network Manager: WPA/WPA2 enterprise networks
		- conflicting design languages
			- lower radius on network-manager
			- network-manager util should live as an applet
	- finish calculator
	- emoji selector

- wallpapers
	- test timestamp based table: { ["0:00"] = "/path/to/image" }
	- looks like shit with light wallpaper

- custom polkit

- unit tests where possible
	- https://github.com/norman/telescope
	- better unit tests - tests/ directory

- set `inode/directory` mimetype to use thunar over VS Code 

- rework battery widget
	- click on it -> applet w/ powertop-like stats

- no way to switch audio sink

- Promises
	- Use them
	- switch from util.Promise to an actual promise provider

- limit hovered clients to 1 while using screen preview
	- should fix mousegrabber issue

- multihead
	- brightness keys / control center controls an arbitrary display
	- screen_preview is broken w/ multiple monitors

- hover titlebar buttons

- figure out why tf appmenus don't work on awesome-luajit

- types
	- generate type annotations for awesome from the docs

- break keys out from rc.lua
	- configurable?

- hot reloading? perchance?
	- https://github.com/anton-kl/lua-hot-reload