---@meta

---@class DotfileConfigurationDecorations
---@field titlebar { pos: Direction }
---@field colors Color[]

---@class DotfileConfigurationTaskbar
---@field bg Color
---@field widget_bg Color
---@field border_width number
---@field gap number
---@field top number
---@field left number

---@class DotfileConfigurationTag
---@field focus Color
---@field empty Color
---@field occupied Color
---@field urgent Color

---@class DotfileConfigurationPopup
---@field bg Color
---@field fg Color
---@field border Color?

---@class DotfileConfigurationProgressbar
---@field bg Color
---@field fg Color

---@class DotfileConfigurationButton
---@field normal Color
---@field hover Color
---@field active Color

---@class DotfileConfigurationApps
---@field terminal string
---@field editor string
---@field file_manager string
---@field compositor string|nil

---@class DotfileConfigurationGimmicks
---@field gestures boolean
---@field pywal boolean
---@field global_menu boolean
---@field screen_preview boolean

---@class DotfileConfigurationApplets
---@field screenshot boolean
---@field calculator boolean

---@class DotfileConfiguration
---@field decorations DotfileConfigurationDecorations
---@field border { floating_width: number, tiled_width: number }
---@field taskbar DotfileConfigurationTaskbar
---@field tag DotfileConfigurationTag
---@field popup DotfileConfigurationPopup
---@field progressbar DotfileConfigurationProgressbar
---@field button DotfileConfigurationButton
---@field gap number
---@field font string
---@field apps DotfileConfigurationApps
---@field notification_lifespan number
---@field gimmicks DotfileConfigurationGimmicks
---@field wallpaper { time: string?, list: table<string, string>|string[] }|string
---@field applet DotfileConfigurationApplets|nil
---@field lock_time number
