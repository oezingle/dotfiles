
local Union = require("src.util.typed.Union")
local String = require("src.util.typed.String")
local Nil = require("src.util.typed.Nil")

-- TODO FIXME this file!

describe("Union", function ()
    it ("Displays nicely", function ()
        local union = Union(String("Hello World"), Nil())

        -- print(union:display())
    end)
end)