
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
	- scroll is iffy
	- kinda boring idk
	- add date/time

- rofi theme
	- a templating engine: follow config.popup colors?

- set xfce4-power-manager lock command
	- `(xfce4-power-manager:1165366): xfce4-power-manager-WARNING **: 23:49:55.146: Screensaver lock command not set when attempting to lock the screen.
Please set the xfconf property /general/LockCommand in xfce4-session to the desired lock command
ERROR: Unknown command 'lock'`
	- `xfconf-query -c xfce4-session -p /general/LockCommand -s "dm-tool lock" --create -t string`
	- https://forum.xfce.org/viewtopic.php?id=14993


- applets
	- math symbols applet
	- Network Manager: WPA/WPA2 enterprise networks
	- conflicting design languages between network-manager util and other applets
		- lower radius on network-manager
		- more transparency for calculator?
		- network-manager util should live as an applet
	- finish calculator
	- emoji selector

- wallpapers	
	- test timestamp based table: { ["0:00"] = "/path/to/image" }
	- looks like shit with light wallpaper
	- wallpaper_changed signal called constantly under xephyr - might be the case with native xorg too?

- uninstall `gtk3-demos` once i've got all my arbitrary_icons sorted

- custom polkit?

- unit tests where possible

- make sure global menu is up to snuff

- set `inode/directory` mimetype to use thunar over VS Code 

- make vscode's terminal ignore `wal -R` in bashrc

- rework battery widget
	- click on it -> applet w/ powertop-like stats

- no way to switch audio sink

- antialias corners
	- https://www.reddit.com/r/awesomewm/comments/kxe1n0/antialiased_rounded_borders/

- switch from util.Promise to oezingle/LuaPromise - better tests, forces me to maintain it

- test under awesome-luajit, switch?

- limit hovererd clients to 1 while using screen preview
	- should fix mousegrabber issue?

- break appmenu/init.lua into appmenu/widget/... - too many helper functions

- restarting awesome breaks firefox's transparency

- multihead
	- brightness keys / control center controls an arbitrary display
	- screen_preview is broken w/ multiple monitors
	- there's only one notification center, but two control centers
		- allow certain widgets on only primary screen
			- notifications button
			- control center
			- battery (if is a laptop)
			- systray

- types
	- generate type annotations for awesome from the docs

- radial menu
	- fancy little layout selector 
		- middle click layout button?