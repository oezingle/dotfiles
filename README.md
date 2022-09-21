
# VHS dotfiles

My little AwesomeWM configuration. Riddled with copyright law breaches. The main attraction is probably my DBus global menu (`appmenu/`). I refuse to document anything but if you want to steal any of my code, go ahead. 

## Stolen Code Appreciation Time

"Whenever Possible, Steal Code" - I stole 95% of this project as any good programmer would
 - `widgets/exit_menu.lua` is lifted from [manilarome/the-glorious-dotfiles](https://github.com/manilarome/the-glorious-dotfiles)
 - `widgets/components/client_preview.lua` is improved from this [Reddit Thread](https://www.reddit.com/r/awesomewm/comments/akiqz2/)
 - `client/restore.lua` is modified from this [Reddit thread](https://www.reddit.com/r/awesomewm/comments/cn02m6/)
 - `util/redshift.lua` is modified from [troglobit/awesome-redshift](https://github.com/troglobit/awesome-redshift)
 - `appmenu/server` wouldn't have been possible without [fbuihuu/samples-dbus](https://github.com/fbuihuu/samples-dbus/blob/master/dbus-client.c)
 - All the icons are stolen from ionicons - I plan to do this in a legal matter soon™

## Features

### App Menu
![global macos-style menu](/media/screenshot/global_menu.png)

### Screen Overview
![macos-style screen overview](/media/screenshot/screen_preview.png)

### Scratch Terminal Selector (Mod+X)
![scratch terminal radial menu](/media/screenshot/scratch_terminal.png)

### Control Center
![control center shows currently playing media](/media/screenshot/control_center_media.png)

### Random Window Decoration Colors
![helps identify windows quickly](/media/screenshot/window_decorations.png)

### System / WM Info Widget
![system load](/media/screenshot/system_load.png)

![wm info](/media/screenshot/window_manager_info.png)

## Stuff You Might Want To Steal
 - `appmenu/` - DBus Appmenu Implementation - Supports GTK and Canonical formats
 - `widgets/components/arbitrary_icon.lua` - GTK icons as Awesome Widgets
 - `widgets/components/cmd_slider.lua` - Upsettingly complex widget that calls a callback when a slider is moved 
 - `widgets/components/select.lua` - Dropdown select menu
 - `widgets/components/switch.lua` - A pretty looking toggle switch
 - `widgets/screen_preview/` - Screen preview/overview/whatever you want to call it
 - `widgets/util/radial_menu/` - Radial menu with buttons and an exit button
 - `widgets/util/pagination.lua` - Multiple pages of widgets
 - `widgets/system_status.lua` - Emoji in top left that shows CPU usage