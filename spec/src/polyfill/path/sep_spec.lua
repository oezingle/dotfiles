
local sep = require("src.polyfill.path.sep")

describe("sep", function ()
    it("is either / or \\", function ()
        assert.truthy(sep == "/" or sep == "\\")
    end)
end)