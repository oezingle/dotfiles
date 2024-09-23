
local Action = require("src.util.Action")

local help = Action.create("help", {
    command = "help",
    on_call = function (self)
        local commands = Action.commands

        local names = {}

        for name, _ in pairs(commands) do
            table.insert(names, name)
        end

        table.sort(names)

        self.log.info("Available Commands:\n\t" .. table.concat(names, " "))
    end
})

return help