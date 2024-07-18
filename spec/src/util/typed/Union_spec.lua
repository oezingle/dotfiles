
local Union = require("src.util.typedd.Union")
local String = require("src.util.typedd.String")
local Nil = require("src.util.typedd.Nil")

-- TODO FIXME this file!

describe("Union", function ()
    it ("Displays nicely", function ()
        local union = Union(String("Hello World"), Nil())

        -- print(union:display())
    end)
end)