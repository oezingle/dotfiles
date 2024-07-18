
local String = require("src.util.typedd.String")

describe("String", function()
    it("displays nicely", function ()
        local string = String("Hello World!")

        assert.equal("string", string:display())
    end)

    it("provides defaults", function ()
        local string = String("Hello World!")

        assert.equal("Hello World!", string:default())
    end)

    it("can be overwritten", function ()
        local string = String("Hello World!")

        assert.equal("overwritten!", string:default("overwritten!"))
    end)
end)
