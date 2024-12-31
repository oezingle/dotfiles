
-- TODO default config easy somehow! (fallback nicely)

local config = {
    meta = {
        providers = {
            LuaHot = {
                poll_rate = 60,
                enabled = false
            }
        }
    },
    notify = {
        log = {
            level = "info"
        }
    }
}

return config