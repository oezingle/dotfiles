local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

---@type DotfileConfiguration
local config = {
    decorations = {
        titlebar = {
            pos = "left",
        },

        -- titlebars are randomly assigned one of these colors.
        -- borders follow suit
        colors = {
            "#1BE7FF", -- neon blue
            "#6CC551", -- lighter green
            "#FF4365", -- light red
            -- "#F1EDEE", -- white
            "#FE5F55", -- salmon
            "#ed9c55", -- pastel orange
        },
    },

    -- Border widths
    border = {
        floating_width = 4,
        tiled_width = 4,
    },

    -- Taskbar configuration
    taskbar = {
        -- Background of the top/left bars
        bg = "#00000000",

        -- Background of the widgets on these bars
        widget_bg = "#66666666",

        -- Borders on the clock / tag indicator
        border_width = 4,

        -- Margin from the edge of the screen to widgets in the taskbar
        gap = 1,

        -- Height of the top bar
        top = 30,

        -- Width of the left bar
        left = 30,
    },

    -- Colors for tag indicators / screen preview
    tag = {
        focus = "#66f",
        empty = "#666",
        occupied = "#fff",
        urgent = "#f66"
    },

    -- Colors for popups
    popup = {
        bg = "#66666688",
        fg = "#ffffff",
    },

    -- Colors for progressbars and sliders
    progressbar = {
        bg = "#666",
        fg = "#fff",
    },

    -- Colors for button elements and some other elements too (I'm lazy!)
    button = {
        normal = "#00000088",
        hover = "#ffffff66",
        active = "#ffffff88"
    },

    -- Gap between tiled windows
    gap = dpi(5),

    -- Font to use in the user interface
    font = "Inter",

    -- User-configured apps
    apps = {
        terminal = "xfce4-terminal",
        editor = os.getenv("EDITOR") or "vim",
    },

    -- How long notifications stay around in the top middle of the screen
    notification_lifespan = 4,

    -- Gimmicky features that can be enabled/disabled as you see fit for your system
    gimmicks = {
        gestures = true,
        pywal = true,
        global_menu = true,
        screen_preview = true
    },

    applet = {
        calculator = false
    },

    -- string[] or table<string, string> where the key is of the form "h:mm".
    -- time: string (parsed to number) or number (number of hours per wallpaper change) or nil
    wallpaper = {
        "/home/zingle/Pictures/wallpaper/JVC 120 ER DARK_8K.png",
        "/home/zingle/Pictures/wallpaper/Scnea HQ T-120_DARK_8K.png",
        "/home/zingle/Pictures/wallpaper/Quasar Video Cassette 60_8K.png",

        -- These ones are kinda boring idk
        -- "/home/zingle/Pictures/wallpaper/Kodak T-120_8K.png",
        -- "/home/zingle/Pictures/wallpaper/Polaroid HQ E-180_8K.png",
        -- "/home/zingle/Pictures/wallpaper/AKAI E-180_8K.png",

        -- TODO make bright wallpapers look good - white font on transparency is hard to read
        -- "/home/zingle/Pictures/wallpaper/TDK SUPER AVILYN DARK_8K.png",
        -- "/home/zingle/Pictures/wallpaper/JVC E-180 DYNAREC_8K.png"

        -- time = "1:00"
    }
}

-- create some commands
config.cmd = {}
config.cmd.editor = config.apps.terminal .. " -e " .. config.apps.editor

-- gimmicks have to be explicitly set to false
for _, gimmick in ipairs({ 
    "gestures",
    "pywal",
    "global_menu",
    "screen_preview"
}) do
    local enabled = config.gimmicks[gimmick]
    
    config.gimmicks[gimmick] = enabled ~= false
end

return config
