
-- TODO default config easy somehow! (fallback nicely)

local config = {
    meta = {
        providers = {
            LuaHot = {
                poll_rate = 2,
                -- enabled = true
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