
# VHS dotfiles

My little AwesomeWM configuration. Riddled with copyright law breaches. The main attraction is probably my DBus global menu (`src/appmenu/`). I refuse to document anything but if you want to steal any of my code, go ahead. 

## Details
 - Font: [Inter](https://rsms.me/inter/)
 - Compositor: [Picom](https://github.com/yshui/picom)
 - GTK Theme: [Materia-theme-transparent](https://github.com/ckissane/materia-theme-transparent)
 - Icons: [WhiteSur-dark](https://github.com/vinceliuice/WhiteSur-icon-theme)
 - Cursor: [LiOS V](https://github.com/im-AMS/LiOSV-cursors)
 - Firefox CSS: [BlurredFox](https://github.com/manilarome/blurredfox) with [this fix](https://github.com/manilarome/blurredfox/issues/68)
 - Terminal: xfce4-terminal
 - File Manager: Thunar

## Installing
```bash
# Copy the default configuration and modify as seen fit
cp config.example.lua config.lua
vim config.lua

# Build the appmenu server (only if you want global menus)
echo $(cd src/appmenu/server; make)
```

## Dependencies
### Required
 - `upower` (battery stats)
 - `awesome` (window manager)
### Optional
 - `appmenu-gtk-module` (appmenus for GTK apps)
 - `whatsapp-ttf-emoji` (little guy in the top left)
 - `inter-fonts` (nice system font)
 - `xorg-xbacklight` (backlight control)
 - `xautolock` (locking after config.lock_time minutes)
 - `polkit-gnome` (GNOME polkit agent)
 - `redshift` (redshift blue light filter)
 - `geoclue` (redshift blue light filter)
 - `libinput-gestures` (gestures, must be configured manually)
 - `pulseaudio` (audio)
 - `python-pywal` (sync terminal/rofi colors to wallpaper)
 - `picom` (compositor)

## Stolen Code

I stole like 95% of this project
 - `widgets/exit_menu.lua` is lifted from [manilarome/the-glorious-dotfiles](https://github.com/manilarome/the-glorious-dotfiles)
 - `widgets/components/client_preview.lua` is improved from this [Reddit Thread](https://www.reddit.com/r/awesomewm/comments/akiqz2/)
 - `client/restore.lua` is modified from this [Reddit thread](https://www.reddit.com/r/awesomewm/comments/cn02m6/)
 - `util/redshift.lua` is modified from [troglobit/awesome-redshift](https://github.com/troglobit/awesome-redshift)
 - `appmenu/server` wouldn't have been possible without [fbuihuu/samples-dbus](https://github.com/fbuihuu/samples-dbus/blob/master/dbus-client.c)
 - All the icons are stolen from ionicons - I plan to do this in a legal manner soon™

## Features

### App Menu
![global macos-style menu](/media/screenshot/global_menu.png)

### Screen Overview
![macos-style screen overview](/media/screenshot/screen_preview.png)

### Scratch Terminal Selector (Mod+X)
![scratch terminal radial menu](/media/screenshot/scratch_terminal.png)

### Control Center
![im a very sad boy](/media/screenshot/control_center_media.png)

### Random Window Decoration Colors
![helps identify windows quickly](/media/screenshot/window_decorations.png)

### System / WM Info Widget
![system load](/media/screenshot/system_load.png)

![wm info](/media/screenshot/window_manager_info.png)

### Features without screenshots
 - Dynamic Wallpapers
 - Cached Wallpaper variants for speed
 - Multihead support (ish)
 - Radial Layout Selector (Ctrl+Mod+F)
 - Emoji CPU load indicator that opens `top` when clicked
 - Alt+Tab client switcher (current tag only)
 - Drag clients to tags in screen preview

## Stuff You Might Want To Steal
 - `src/appmenu/` - DBus Appmenu Implementation - Supports GTK and Canonical formats
 - `src/widgets/components/arbitrary_icon.lua` - GTK icons as Awesome Widgets
 - `src/widgets/components/cmd_slider.lua` - Upsettingly complex widget that calls a callback when a slider is moved 
 - `src/widgets/components/select.lua` - Dropdown select menu
 - `src/widgets/components/switch.lua` - A pretty looking toggle switch
 - `src/widgets/screen_preview/` - Screen preview/overview/whatever you want to call it
 - `src/widgets/util/radial_menu/` - Radial menu with buttons and an exit button
 - `src/widgets/util/pagination.lua` - Multiple pages of widgets
 - `src/widgets/system_status.lua` - Emoji in top left that shows CPU usage
 - `src/util/testable.lua` - simple testing framework. export a testable(module, {...tests}) to enable unit testing for that file. call testable.lua from the terminal to run tests.