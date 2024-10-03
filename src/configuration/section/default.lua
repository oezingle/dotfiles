local typed = require("src.util.typed")
local time = require("src.util.time")

local ConfigurationObject = require("src.configuration.ConfigurationObject")

---@alias Zingle.Awesome.Config.Section.Default.meta { providers: { LuaHot: { enabled: boolean, poll_rate: integer } } }
local meta = ConfigurationObject.create({
    key = "meta",
    display = false,
    children = {
        ConfigurationObject.create({
            key = "providers",
            display = "Enabled Providers",
            type = typed.KeyedTable({
                LuaHot = {
                    enabled = true,
                    -- Polling rate in seconds
                    poll_rate = time():minutes(5):toSeconds()
                }
            }):deep()
        })
    },
    type = typed.Table()
})

---@alias Zingle.Awesome.Config.Section.Default.tasks table<"garbage_collection"|"load_scripts", { timeout: number }>
local tasks = ConfigurationObject.create({
    key = "tasks",
    display = false,
    children = {
        ConfigurationObject.create({
            key = "garbage_collection",
            display = "Garbage collection task settings",
            type = typed.KeyedTable({
                timeout = 30
            }):deep()
        }),
        ConfigurationObject.create({
            key = "load_scripts",
            display = "Dynamic script loading task settings",
            type = typed.KeyedTable({
                timeout = time():minutes(2):toSeconds()
            }):deep()
        })
    },
    type = typed.Table()
})

--[[
---@alias Zingle.Awesome.Config.Section.Default.notify { log: { level: string } }
local notify = ConfigurationObject.create({
    key = "notify",
    display = "Notification settings",
    children = {
        ConfigurationObject.create({
            key = "log",
            display = false,
            type = typed.KeyedTable({
                level = "error"
            }):deep()
        })
    },
    type = typed.Table()
})
]]

---@alias Zingle.Awesome.Config.Section.Default.wm { layouts: (function|string)[] }
local wm = ConfigurationObject.create({
    key = "wm",
    display = "Window Manager settings",
    children = {
        ConfigurationObject.create({
            key = "layouts",
            display = "Window Layouts",
            type = typed.Table({
                "awful.layout.suit.tile",
                "awful.layout.suit.tile.left",
                "awful.layout.suit.floating",
                -- "awful.layout.suit.tile.bottom",
                "awful.layout.suit.tile.top",
                "awful.layout.suit.fair",
                "awful.layout.suit.fair.horizontal",
                "awful.layout.suit.spiral",
                -- "awful.layout.suit.spiral.dwindle",
                -- "awful.layout.suit.max",
                -- "awful.layout.suit.max.fullscreen",
                "awful.layout.suit.magnifier",
                "awful.layout.suit.corner.nw",
                -- "awful.layout.suit.corner.ne",
                -- "awful.layout.suit.corner.sw",
                -- "awful.layout.suit.corner.se",
            })
        })
    },
    type = typed.Table()
})


---@class Zingle.Awesome.Config.Section.Default 
---@field meta Zingle.Awesome.Config.Section.Default.meta
---@field wm Zingle.Awesome.Config.Section.Default.wm
---@field tasks Zingle.Awesome.Config.Section.Default.tasks
local object = ConfigurationObject.create({
    key = "DEFAULT",
    children = {
        meta,
        wm,
        tasks,
    },
    type = typed.Table()
})

return object
