---@meta

---@alias RootFakeKeyInput fun(event_type: "key_press"|"key_release", char: string|"Super_L"|"Control_L"|"Shift_L"|"Alt_L"|"Super_R"|"Control_R"|"Shift_R"|"Alt_R")
---@alias RootFakeMouseInput fun(event_type: "button_press"|"button_release", detail: MouseButton)
---@alias RootFakeMotionInput fun(event_type: "motion_notify", relative: boolean, x: integer, y: integer)

---@class Root
---@field fake_input RootFakeKeyInput|RootFakeMouseInput|RootFakeMotionInput Send fake keyboard or mouse events. [Link](https://awesomewm.org/doc/api/libraries/root.html#fake_input)
---@field keys GetterOrSetter<Key[]> Get or set global key bindings. These bindings will be available when you press keys on the root window. [Link](https://awesomewm.org/doc/api/libraries/root.html#keys)
---@field buttons GetterOrSetter<Button[]> Get or set global mouse bindings. This binding will be available when you click on the root window. [Link](https://awesomewm.org/doc/api/libraries/root.html#buttons)
---@field cursor fun(cursor_name: "num_glyphs" | "cursor" | "arrow" | "based_arrow_down" | "based_arrow_up" | "boat" | "bogosity" | "bottom_left_corner" | "bottom_right_corner" | "bottom_side" | "bottom_tee" | "box_spiral" | "center_ptr" | "circle" | "clock" | "coffee_mug" | "cross" | "cross_reverse" | "crosshair" | "diamond_cross" | "dot" | "dotbox" | "double_arrow" | "draft_large" | "draft_small" | "draped_box" | "exchange" | "fleur" | "gobbler" | "gumby" | "hand" | "hand" | "heart" | "icon" | "iron_cross" | "left_ptr" | "left_side" | "left_tee" | "leftbutton" | "ll_angle" | "lr_angle" | "man" | "middlebutton" | "mouse" | "pencil" | "pirate" | "plus" | "question_arrow" | "right_ptr" | "right_side" | "right_tee" | "rightbutton" | "rtl_logo" | "sailboat" | "sb_down_arrow" | "sb_h_double_arrow" | "sb_left_arrow" | "sb_right_arrow" | "sb_up_arrow" | "sb_v_double_arrow" | "shuttle" | "sizing" | "spider" | "spraycan" | "star" | "target" | "tcross" | "top_left_arrow" | "top_left_corner" | "top_right_corner" | "top_side" | "top_tee" | "trek" | "ul_angle" | "umbrella" | "ur_angle" | "watch" | "xterm") Set the root cursor. [Link](https://awesomewm.org/doc/api/libraries/root.html#cursor)
---@field drawins fun(): unknown[] Get the drawins attached to a screen. [Link](https://awesomewm.org/doc/api/libraries/root.html#drawins)
---@field wallpaper fun(pattern: Surface) Get the wallpaper as a cairo surface or set it as a cairo pattern. [Link](https://awesomewm.org/doc/api/libraries/root.html#wallpaper)
---@field size fun(): integer, integer Get the size of the root window. [Link](https://awesomewm.org/doc/api/libraries/root.html#size)
---@field size_mm fun(): integer, integer Get the physical size of the root window, in millimeter. [Link](https://awesomewm.org/doc/api/libraries/root.html#size_mm)
---@field tags fun(): Tag[] Get the attached tags. [Link](https://awesomewm.org/doc/api/libraries/root.html#tags)
