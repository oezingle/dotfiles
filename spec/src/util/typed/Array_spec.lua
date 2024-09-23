local String = require("src.util.typed.String")
local Array = require("src.util.typed.Array")
local assert_deep_equals = require("spec.helper.assert_deep_equals")

describe("Array", function()
    it("Displays nicely", function()
        local array = Array(String("Hello World!"))

        assert.equal("string[]", array:display())
    end)

    it("Steals defaults from passed types", function ()
        local array = Array(String("Hello World!"))

        assert_deep_equals({ "Hello World!" }, array:default())
    end)

    it("Allows custom defaults", function ()
        local array = Array(String("bruh"), { "Hello", "World" })

        assert_deep_equals({ "Hello", "World" }, array:default())
    end)

    it("Allows overrides of defaults", function ()
        local array = Array(String("Hello World!"))

        assert_deep_equals({ "Hello Bro" }, array:default({ "Hello Bro" }))
    end)
end)
