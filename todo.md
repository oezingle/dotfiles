
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
	- first-class multimonitor support
	- component for wallpaper images so sizes don't have to be explicitly set
	- small visuak bug rn with occupied tags ( no border )[ might have something to do with wallpaper_widget ]

- Use pre-built buttons

- find a way to change GTK theme on the fly
	- Materia seems to have no difference (this is an L)
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

- antialiased corners? https://github.com/elenapan/dotfiles/wiki/Rounded-corners

- border for appmenu popups

- some sort of service for features to register their /sh/ hooks so that the sh file doesn't have to do as much heavy lifting

- write utils to turn signals into async CLIs
	- require('cli')() -> keyboard-prompted utils CLI
	- cli:: signal namespace
	- rebuild sh as an almost `systemctl` util - restart, stop, start services for features

- battery widget does not react to pywal changes

- Use dbus.smart_proxy_2

- sort out weird fucking bugs with xfsettingsd setting gtk theme to Materia-transparent-light
	- pywal related?

- https://github.com/Drauthius/awesome-sharedtags
	- optional?

- fix wal_svg for battery widget

- remove any uses of require("lib.test").has_awesome in favor of simple `if awesome then ... end` syntax

- avoid querying globals - maybe can be detected with _ENV