
local typed = require("src.typed")

local ConfigurationObject = require("src.configuration.ConfigurationObject")

---@alias Zingle.Awesome.Config.Section.Default.meta { providers: { LuaHot: { enabled: boolean, poll_rate: integer } } }

---@alias Zingle.Awesome.Config.Section.Default { meta: Zingle.Awesome.Config.Section.Default.meta }

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
    }
})

local object = ConfigurationObject.create({
    key = "DEFAULT",
    children = {
        meta
    },
    type = typed.Table()
})

return object
