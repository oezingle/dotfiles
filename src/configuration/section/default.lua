
local typed = require("src.typed")

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
                    poll_rate = 1
                }
            }):deep()
        })
    },
    type = typed.Table()
})

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

---@alias Zingle.Awesome.Config.Section.Default { meta: Zingle.Awesome.Config.Section.Default.meta, notify: Zingle.Awesome.Config.Section.Default.notify }
local object = ConfigurationObject.create({
    key = "DEFAULT",
    children = {
        meta,
        notify
    },
    type = typed.Table()
})

return object
