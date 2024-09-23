
local Action = require("src.util.Action")

local help = Action.create("exit", {
    command = "exit",
    on_call = function ()
        print("Goodbye!")

        os.exit(1)
    end
})

return help