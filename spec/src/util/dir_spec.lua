
local dir = require("src.util.dir")
local fs  = require("src.util.fs")

describe("dir", function ()
    it("accurately gets asset dir", function ()
        assert.has.match("asset", dir.asset())
    end)

    it("accurately gets asset/awesome", function ()
        assert.has.match("asset/awesome", dir.asset.awesome())
    end)

    it("accurately gets asset/awesome/core/cli", function ()
        assert.has.match("asset/awesome/core/cli", dir.asset.awesome.core.cli())
    end)

    it("accurately gets files", function ()
        local path = dir.asset.awesome.core.cli("DBusNode.xml")

        assert(fs.exists(path))
    end)
end)