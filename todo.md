
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

- refactor widgets
	- widgets/components -> anything completed (music, control_center, etc)
	- widgets/helper -> utilities, bobbins, applet toolkit

- Use pre-built buttons