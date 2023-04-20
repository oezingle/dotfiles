
- task bar
	- calendar (click clock)

- improve notification center
	- add date/time

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

- time doesn't localize

- default app selector (through rofi?)

- configuration interface

- translations everywhere

- Xorg intel config
	- [disable TearFree, TripleBuffer, SwapbuffersWait](https://wiki.archlinux.org/title/Intel_graphics#Disabling_TearFree,_TripleBuffer,_SwapbuffersWait)

- rebuild screen preview

- Use pre-built buttons

- find a way to change GTK theme on the fly
	- Materia-light vs dark
	- xfsettingsd + xconf
		- https://docs.xfce.org/xfce/xfce4-settings/xfsettingsd
		- `xfconf-query -c xsettings -p /Net/ThemeName`
		- change icon theme too
		- i had another idea that had something to do with macOs but i forget it
		- on startup:
			- start xfsettingsd ( requires `xfce4-settings` )
			- query active GTK/icon themes
			- exit hook to restore themes
			- search dir of active GTK theme for a dark variant (generally name-dark or namedark)
			- if light wallpaper (for the love of god, cache the 1x1 or the is_light state or something), then set to light. If dark, set to dark.
		- applet hook for `settings` to open xfce4-settings-manager
		- make sure these dependencies are optional

- a way to disable light wallpaper checks