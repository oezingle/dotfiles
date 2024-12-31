local StyleContext = require("lib.LuaX").Context.create({
    font = {
        family = "Arial",
        size = {
            default = 12,

            title = 16,
            subtitle = 14,

            -- TODO better name field
            subtext = 10,
        },
    }
})

return StyleContext
