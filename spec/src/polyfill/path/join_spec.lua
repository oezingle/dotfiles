local join = require("src.polyfill.path.join")
local sep = require("src.polyfill.path.sep")

local function r (str)
    str = str:gsub("%-", sep)

    return str
end

describe("join", function ()
    it("joins strings without slashes", function ()
        assert.equal(r("awesome-core"), join("awesome", "core"))
    end)

    it("joins two relative paths", function ()
        assert.equal(r(".-awesome-core"), join(r(".-awesome"), r(".-core")))
    end)

    it("joins an absolute path and a relative path", function ()
        assert.equal(r("-home-zingle"), join(r("-home"), r("zingle")))
    end)

    it("joins an absolute and a relative path", function ()
        assert.equal(r("-home"), join(r"-", r"home"))
    end)
end)