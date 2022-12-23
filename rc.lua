-- rebind print
print = require("src.agnostic.print")

print(string.rep("\n", 5) .. "AWESOMEWM RESTART" .. string.rep("\n", 5))

-- seed random
math.randomseed(os.time())
-- some platforms have a recurring first random
math.random()
math.random()
math.random()

local error_log = require("src.error_log")

local unpack = require("src.agnostic.version.unpack")

local Alt = "Mod1"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")

local config = require("config")

local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local create_exit_screen = require("src.widgets.exit_menu")
local scratch_terminal = require("src.widgets.scratch_terminal")

-- Include event handlers
require("src.on_layout_change")
require("src.client")

-- Run shell stuff
require("src.sh")

-- notifications
require("src.notify")

-- Set up taskbar
local create_taskbar = require("src.taskbar")
create_taskbar()

local layout_selector = require("src.widgets.layout_selector")

-- allow screen preview
if config.gimmicks.screen_preview then
    require("src.widgets.screen_preview")
end

-- allow client switcher
require("src.widgets.client_switcher")()

-- Get applets
require("src.widgets.applet")

-- set wallpaper
local get_wallpaper = require("src.util.get_wallpaper")

-- Rofi popup
local rofi = require('src.sh').rofi

-- Themes define colours, icons, font and wallpapers.
-- beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.init(gears.filesystem.get_configuration_dir() .. "mytheme.lua")

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    --awful.layout.suit.tile.left,
    awful.layout.suit.floating,
    --awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.max,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}

-- restore saved WM state
gears.timer.delayed_call(function()
    require("src.save_state.wm").restore_tags()
end)

local function set_wallpaper(s)
    gears.wallpaper.maximized(get_wallpaper(s.geometry.width, s.geometry.height), s, true)
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awesome.connect_signal("wallpaper_should_change", function()
    for s in screen do
        set_wallpaper(s)
    end
end)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Create Exit menu
    create_exit_screen(s)

    -- create tags
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.suit.floating)
end)

-- {{{ Key bindings
local globalkeys = gears.table.join(

-- TODO change this binding
-- awful.key({ modkey, }, "s", hotkeys_popup.show_help,
--     { description = "show help", group = "awesome" }),

    awful.key({ modkey, }, "Left", awful.tag.viewprev,
        { description = "view previous", group = "tag" }),
    awful.key({ modkey, }, "Right", awful.tag.viewnext,
        { description = "view next", group = "tag" }),
    awful.key({ modkey, }, "Escape", awful.tag.history.restore,
        { description = "go back", group = "tag" }),

    awful.key({ modkey, }, "x", scratch_terminal,
        { description = "Run a scratch terminal" }),


    awful.key({ modkey, }, "j",
        function()
            awful.client.focus.byidx(1)
        end,
        { description = "focus next by index", group = "client" }
    ),
    awful.key({ modkey, }, "k",
        function()
            awful.client.focus.byidx(-1)
        end,
        { description = "focus previous by index", group = "client" }
    ),

    -- Layout manipulation
    awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
        { description = "swap with next client by index", group = "client" }),
    awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
        { description = "swap with previous client by index", group = "client" }),
    awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
        { description = "focus the next screen", group = "screen" }),
    awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
        { description = "focus the previous screen", group = "screen" }),
    awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
        { description = "jump to urgent client", group = "client" }),

    -- Standard program
    awful.key({ "Control", Alt }, "t", function() awful.spawn(config.apps.terminal) end,
        { description = "open a terminal", group = "launcher" }),
    awful.key({ modkey }, "e", function() awful.spawn(config.apps.file_manager) end,
        { description = "open a file manager", group = "launcher" }),

    awful.key({ modkey, "Control" }, "r", awesome.restart,
        { description = "reload awesome", group = "awesome" }),
    awful.key({ modkey, "Shift" }, "q", awesome.quit,
        { description = "quit awesome", group = "awesome" }),

    -- resize clients
    awful.key({ modkey, }, "d", function() awful.tag.incmwfact(0.05) end,
        { description = "increase master width factor", group = "layout" }),
    awful.key({ modkey, }, "a", function() awful.tag.incmwfact(-0.05) end,
        { description = "decrease master width factor", group = "layout" }),
    awful.key({ modkey, }, "w", function() awful.client.incwfact(0.05) end,
        { description = "increase master width factor", group = "layout" }),
    awful.key({ modkey, }, "s", function() awful.client.incwfact(-0.05) end,
        { description = "decrease master width factor", group = "layout" }),

    -- increase/decrease master client count
    awful.key({ modkey, "Shift" }, "w", function() awful.tag.incnmaster(1, nil, true) end,
        { description = "increase the number of master clients", group = "layout" }),
    awful.key({ modkey, "Shift" }, "s", function() awful.tag.incnmaster(-1, nil, true) end,
        { description = "decrease the number of master clients", group = "layout" }),

    -- increase/decrease columns
    awful.key({ modkey, "Shift" }, "a", function() awful.tag.incncol(1, nil, true) end,
        { description = "increase the number of columns", group = "layout" }),
    awful.key({ modkey, "Shift" }, "d", function() awful.tag.incncol(-1, nil, true) end,
        { description = "decrease the number of columns", group = "layout" }),

    -- switch layouts
    awful.key({ modkey, }, "f", function() awful.layout.inc(1, nil, awful.layout.layouts) end,
        { description = "select next", group = "layout" }),
    awful.key({ modkey, "Shift" }, "f", function() awful.layout.inc(-1, nil, awful.layout.layouts) end,
        { description = "select previous", group = "layout" }),
    awful.key({ modkey, "Control" }, "f", function() layout_selector() end,
        { description = "select visually", group = "layout" }),

    -- restore minimized
    awful.key({ modkey, "Shift" }, "n",
        function()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                c:emit_signal(
                    "request::activate", "key.unminimize", { raise = true }
                )
            end
        end,
        { description = "restore minimized", group = "client" }),

    -- rofi
    awful.key({ modkey }, "space", rofi,
        { description = "run prompt", group = "launcher" })
)

local clientkeys = gears.table.join(
-- Quit client
    awful.key({ "Control", "Shift" }, "q", function(c) c:kill() end,
        { description = "close", group = "client" }),

    -- Toggle floating / tiling
    awful.key({ modkey }, "r", awful.client.floating.toggle,
        { description = "toggle floating", group = "client" }),

    awful.key({ modkey, }, "q", function(c) c:swap(awful.client.getmaster()) end,
        { description = "move to master", group = "client" }),
    awful.key({ modkey, }, "o", function(c) c:move_to_screen() end,
        { description = "move to screen", group = "client" }),

    awful.key({ modkey, }, "t", function(c) c.ontop = not c.ontop end,
        { description = "toggle keep on top", group = "client" }),

    -- Minimize client
    awful.key({ modkey, }, "n",
        function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
        { description = "minimize", group = "client" }),

    -- Maximize client
    awful.key({ modkey, }, "m",
        function(c)
            c.maximized = not c.maximized
            c:raise()
        end,
        { description = "(un)maximize", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            { description = "view tag #" .. i, group = "tag" }),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            { description = "toggle tag #" .. i, group = "tag" }),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            { description = "move focused client to tag #" .. i, group = "tag" }),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            { description = "toggle focused client on tag #" .. i, group = "tag" })
    )
end

-- append volume keys
globalkeys = gears.table.join(
    globalkeys,
    unpack(require("src.widgets.volume_and_brightness").keys)
)

-- append screen preview keys
globalkeys = gears.table.join(
    globalkeys,
    awful.key({ modkey }, "Tab", function()
        awesome.emit_signal("screen_preview::toggle")
    end, {
        description = "Toggle Screen Overview"
    }),

    awful.key({ Alt }, "Tab", function()
        awesome.emit_signal("client_switcher::show")
    end)
)

-- append printscreen
globalkeys = gears.table.join(
    globalkeys,
    awful.key({}, "Print", function()
        Screenshot.toggle()
    end)
)

local clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    awful.button({ modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = {},
        properties = { border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,

            placement = awful.placement.centered
        }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
            "DTA", -- Firefox addon DownThemAll.
            "copyq", -- Includes session name in class.
            "pinentry",
        },
        class = {
            "Arandr",
            "Blueman-manager",
            "Gpick",
            "Kruler",
            "MessageWin", -- kalarm.
            "Sxiv",
            "KColorChooser",
            "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
            "Wpa_gui",
            "veromix",
            "xtightvncviewer"
        },

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
            "Event Tester", -- xev.
        },
        role = {
            "AlarmWindow", -- Thunderbird's calendar.
            "ConfigManager", -- Thunderbird's about:config.
            "pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
        }
    }, properties = { floating = true } },

    -- Add titlebars to normal clients and dialogs
    { rule_any = { type = { "normal", "dialog" } },
        properties = {
            titlebars_enabled = true
        }
    },

    -- make firefox PiP sticky
    { rule = { name = "Picture-in-Picture", },
        properties = {
            sticky = true
        }
    },
}

-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

-- allow unit tests
require("test.init")

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors })

    if error_log then
        error_log(awesome.startup_errors, true)
    end
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err) })

        error_log(tostring(err))

        in_error = false
    end)
end

-- Garbage collection
gears.timer.start_new(10, function() collectgarbage("step", 20000) return true end)
