
local list_reverse = require("src.polyfill.list.reverse")

describe("list_reverse", function ()
    it("reverses a list", function ()
        local rev = list_reverse({ 1, 2, 3 })

        local exp = { 3, 2, 1 }
        assert.equal(exp[1], rev[1])
        assert.equal(exp[2], rev[2])
        assert.equal(exp[3], rev[3])
    end)
end)