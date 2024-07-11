
local Union = require("src.typed.Union")
local String = require("src.typed.String")
local Nil = require("src.typed.Nil")

-- TODO FIXME this file!

describe("Union", function ()
    it ("Displays nicely", function ()
        local union = Union(String("Hello World"), Nil())

        -- print(union:display())
    end)
end)