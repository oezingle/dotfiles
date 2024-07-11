local typed = require("typed")

describe("typed", function()
    it("checks", function()
        local type = typed.Array(typed.Union(typed.String("Hello"), typed.Nil()))

        typed.check(type, { "Beef", nil })
    end)

    it("provides defaults", function ()
        local type = typed.Array(typed.String(), { "Hello", "World" })

        assert.equal("Hello World", table.concat(typed.default(type), " "))
    end)
end)
